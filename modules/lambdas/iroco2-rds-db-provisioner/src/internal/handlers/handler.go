package handlers

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"slices"
	"strconv"
	"strings"

	log "github.com/sirupsen/logrus"
	secrets "github.com/ippontech/iroco2-terraform-modules/modules/lambdas/iroco2-rds-db-provisioner/src/internal/secrets"
	service "github.com/ippontech/iroco2-terraform-modules/modules/lambdas/iroco2-rds-db-provisioner/src/internal/service"
	types "github.com/ippontech/iroco2-terraform-modules/modules/lambdas/iroco2-rds-db-provisioner/src/internal/types"
)

func LoadConnectionInfo() (*types.ConnectionInfo, error) {
	var missing []string
	log.Infof("loading environment variables")

	host := os.Getenv("DB_HOST")
	portStr := os.Getenv("DB_PORT")
	dbname := os.Getenv("DB_NAME")
	user := os.Getenv("DB_USER")
	pass := os.Getenv("DB_PASSWORD")
	passwordArn := os.Getenv("DB_PASSWORD_ARN")
	ssl := os.Getenv("SSL_MODE")
	driver := os.Getenv("DB_DRIVER")
	secretsProviderName := os.Getenv("SECRETS_PROVIDER")
	logLevel := os.Getenv("LOG_LEVEL")

	if logLevel == "" {
		logLevel = "info"
	}
	level, err := log.ParseLevel(strings.ToLower(logLevel))
	if err != nil {
		level = log.InfoLevel
	}
	log.SetLevel(level)

	if host == "" {
		missing = append(missing, "DB_HOST")
	}
	if portStr == "" {
		missing = append(missing, "DB_PORT")
	}
	if dbname == "" {
		missing = append(missing, "DB_NAME")
	}
	if user == "" {
		missing = append(missing, "DB_USER")
	}
	if ssl == "" {
		missing = append(missing, "SSL_MODE")
	}
	if driver == "" {
		missing = append(missing, "DB_DRIVER")
	}
	if secretsProviderName == "" {
		missing = append(missing, "SECRETS_PROVIDER")
	}
	if len(missing) > 0 {
		return nil, fmt.Errorf("missing required environment variables: %v", strings.Join(missing, ", "))
	}

	if passwordArn == "" && pass == "" {
		return nil, fmt.Errorf("one of DB_PASSWORD or DB_PASSWORD_ARN environment variables must be set")
	}

	port, err := strconv.Atoi(portStr)
	if err != nil {
		log.Errorf("invalid DB_PORT value: %v", err)
		return nil, err
	}

	allowedDrivers := []string{"postgres", "mysql"}
	if !slices.Contains(allowedDrivers, driver) {
		return nil, fmt.Errorf(
			"invalid value '%s' for DB_ENGINE. Allowed values: %s",
			driver, strings.Join(allowedDrivers, ", "),
		)
	}

	validSSLModes := []string{"disable", "allow", "prefer", "require"}
	if !slices.Contains(validSSLModes, ssl) {
		return nil, fmt.Errorf(
			"invalid value '%s' for SSL_MODE. Allowed values: %s",
			driver, strings.Join(validSSLModes, ", "),
		)
	}

	// TODO: move to more appropriate location and make it provider agnostic
	if pass == "" {
		client, err := secrets.NewSecretsManagerClient()
		if err != nil {
			return nil, err
		}
		secretsProvider := secrets.AWSSecretsProvider{Manager: client}
		pass, err = secretsProvider.GetSecretManagerPassword(passwordArn, "password")
	}

	return &types.ConnectionInfo{
		Host:            host,
		Port:            port,
		User:            user,
		Password:        pass,
		SSLMode:         ssl,
		Driver:          driver,
		DefaultDatabase: dbname,
		SecretsProvider: secretsProviderName,
	}, nil
}

func LambdaHandler(ctx context.Context, event json.RawMessage) error {
	log.Println("Lambda handler started")
	var req ProvisionRequest
	if err := json.Unmarshal(event, &req); err != nil {
		log.Errorf("failed to unmarshall payload. %s", err)
		return err
	}

	connInfo, err := LoadConnectionInfo()
	if err != nil {
		log.Fatalf("failed to load required environment variables. %v", err)
		return err
	}

	secretsProvider, err := secrets.NewSecretsProvider(connInfo.SecretsProvider)
	if err != nil {
		log.Fatalf("error during secrets provider ")
		return err
	}

	if err := req.Validate(connInfo.Driver); err != nil {
		log.Errorf("failed to validate request.")
		return err
	}

	handler, err := service.NewDatabaseConnection(*connInfo, connInfo.DefaultDatabase)
	if err != nil {
		return err
	}
	defer handler.Engine.Close()

	log.Info("creating databases")
	for _, dbname := range req.Databases {
		err := handler.HandleDatabaseRequest(dbname)
		if err != nil {
			log.Errorf("error creating database %s: %v", dbname, err)
			return err
		}
	}

	log.Info("Creating roles")
	for _, r := range req.Roles {
		err := handler.HandleRoleRequest(r)
		if err != nil {
			log.Errorf("error creating role %s: %v", r.Name, err)
			return err
		}
	}

	log.Info("Creating users")
	for _, u := range req.Users {
		password, err := secretsProvider.ResolvePassword(u)
		if err != nil {
			log.Errorf("error while trying to resolve password for user %s", u.Name)
			return err
		}
		err = handler.HandleUserRequest(u, password)
		if err != nil {
			log.Errorf("error creating user %s: %v", u.Name, err)
			return err
		}
	}

	log.Info("Creating schemas")
	for _, s := range req.Schemas {
		err := handler.HandleSchemaRequest(s)
		if err != nil {
			log.Errorf("error creating schema %s: %v", s.Name, err)
			return err
		}
	}

	log.Info("Creating grants")
	for _, g := range req.Grants {
		err := handler.HandleGrantRequest(g)
		if err != nil {
			log.Errorf("error granting privileges to %s on %s: %v", g.GrantTo, g.Target, err)
			return err
		}
	}

	log.Info("Creating autogrants")
	for _, ag := range req.AutoGrants {
		err := handler.HandleAutoGrantRequest(ag)
		if err != nil {
			log.Errorf("error altering default privileges for '%s': %v", ag.Grantee, err)
			return err
		}
	}

	log.Info("All resources have been created!")
	return nil
}
