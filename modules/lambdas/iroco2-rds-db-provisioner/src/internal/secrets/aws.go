package secrets

import (
	"encoding/json"
	"fmt"
	"os"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/secretsmanager"
	log "github.com/sirupsen/logrus"
	types "github.com/ippontech/iroco2-terraform-modules/modules/lambdas/iroco2-rds-db-provisioner/src/internal/types"
)

func NewSecretsManagerClient() (*secretsmanager.SecretsManager, error) {
	region := os.Getenv("AWS_REGION")
	log.Debugf("initializing new secretsmanager session with region %s", region)
	if region == "" {
		return nil, fmt.Errorf("environment variable AWS_REGION was not set.")
	}
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(region),
	})
	if err != nil {
		return nil, err
	}

	return secretsmanager.New(sess), nil
}

type AWSSecretsProvider struct {
	Manager *secretsmanager.SecretsManager
}

func (p *AWSSecretsProvider) ResolvePassword(user types.User) (string, error) {
	if user.PasswordArn != "" {
		pass, err := p.GetSecretManagerPassword(user.PasswordArn, "password") // TODO: Add support for other password keys
		if err != nil {
			return "", err
		}
		return pass, nil
	}
	if user.Password != "" {
		return user.Password, nil
	}
	log.Debugf("no password provided for user %s", user.Name)
	return "", nil
}

func ExtractPassword(secretString string, secretKey string) (string, error) {
	var secretMap map[string]string
	err := json.Unmarshal([]byte(secretString), &secretMap)
	if err != nil {
		log.Errorf("failed to unmarshal secret string")
		return "", err
	}

	password, ok := secretMap[secretKey]
	if !ok {
		return "", fmt.Errorf("key 'password' not found in secret")
	}
	return password, nil
}

func (p *AWSSecretsProvider) GetSecretManagerPassword(secretArn string, secretKey string) (string, error) {
	log.Infof("fetching password with arn %s and key '%s'", secretArn, secretKey)
	manager := p.Manager
	input := &secretsmanager.GetSecretValueInput{
		SecretId: aws.String(secretArn),
	}
	pwd, err := manager.GetSecretValue(input)
	if err != nil {
		return "", fmt.Errorf("error fetching secret %s: %w", secretArn, err)
	}
	if pwd.SecretString == nil {
		return "", fmt.Errorf("secret %s has no string value (maybe binary?)", secretArn)
	}
	pass, err := ExtractPassword(*pwd.SecretString, secretKey)
	if err != nil {
		return "", fmt.Errorf("could not extract secret with key '%s': %w", secretKey, err)
	}
	return pass, nil
}
