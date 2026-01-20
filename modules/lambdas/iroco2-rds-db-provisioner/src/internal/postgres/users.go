package postgres

import (
	"fmt"

	log "github.com/sirupsen/logrus"

	"github.com/lib/pq"
	types "github.com/ippontech/iroco2-terraform-modules/modules/lambdas/iroco2-rds-db-provisioner/src/internal/types"
)

func (db *PostgresService) CreateUser(user types.User) error {
	query := fmt.Sprintf(
		"CREATE USER %s WITH LOGIN;",
		pq.QuoteIdentifier(user.Name),
	)
	log.Debug(query)
	_, err := db.Conn.Exec(query)
	return err
}

func (db *PostgresService) UpdateUserAuth(user types.User, password string) error {

	// If password is provided, append query accordingly
	// If no password is provided, you need to grant rds_iam role to your user for iam auth
	passwordStr := ""
	if password != "" {
		passwordStr = fmt.Sprintf("PASSWORD %s", quoteLiteral(password))
	}
	query := fmt.Sprintf(
		"ALTER ROLE %s WITH LOGIN %s;",
		pq.QuoteIdentifier(user.Name),
		passwordStr,
	)
	log.Debug(query)
	_, err := db.Conn.Exec(query)
	return err
}

func (db *PostgresService) UpdateRoles(user types.User) error {
	for _, r := range user.Roles {
		err := db.GrantRole(user, r)
		if err != nil {
			log.Errorf("failed to grant role %s to %s. %v", r, user.Name, err)
			return err
		}
	}
	return nil
}

func (db *PostgresService) GrantRole(user types.User, role string) error {
	query := fmt.Sprintf(
		"GRANT %s TO %s",
		pq.QuoteIdentifier(role),
		pq.QuoteIdentifier(user.Name),
	)
	log.Debug(query)
	_, err := db.Conn.Exec(query)
	return err
}

func (db *PostgresService) CheckUserExists(user types.User) (bool, error) {
	var exists bool
	query := `SELECT EXISTS(SELECT 1 FROM pg_roles WHERE rolname = $1);`
	log.Debug(query)
	err := db.Conn.QueryRow(query, user.Name).Scan(&exists)
	if err != nil {
		return false, err
	}
	return exists, nil
}
