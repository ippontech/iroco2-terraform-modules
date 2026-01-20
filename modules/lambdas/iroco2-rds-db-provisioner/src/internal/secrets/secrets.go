package secrets

import (
	log "github.com/sirupsen/logrus"

	types "github.com/ippontech/iroco2-terraform-modules/modules/lambdas/iroco2-rds-db-provisioner/src/internal/types"
)

type SecretsProvider interface {
	ResolvePassword(user types.User) (string, error)
}

func NewSecretsProvider(provider string) (SecretsProvider, error) {
	log.Infof("initializing the secrets provider")

	if provider == "AWS" {
		log.Debugf("using AWS secret provider")
		sm, err := NewSecretsManagerClient()
		if err != nil {
			log.Fatalf("could not instantiate secretsmanager")
			return nil, err
		}
		return &AWSSecretsProvider{Manager: sm}, nil
	}
	log.Info("no secrets provider specified. Skipping provider instantiation")
	return nil, nil
}
