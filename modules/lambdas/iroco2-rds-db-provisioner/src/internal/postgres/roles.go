package postgres

import (
	"fmt"

	log "github.com/sirupsen/logrus"
	types "github.com/ippontech/iroco2-terraform-modules/modules/lambdas/iroco2-rds-db-provisioner/src/internal/types"
)

func (db *PostgresService) CheckRoleExists(role types.Role) (bool, error) {
	var exists bool
	query := `SELECT EXISTS(SELECT 1 FROM pg_roles WHERE rolname = $1);`
	log.Debug(query)
	err := db.Conn.QueryRow(query, role.Name).Scan(&exists)
	if err != nil {
		return false, err
	}
	return exists, nil
}

func (db *PostgresService) CreateRole(role types.Role) error {
	query := fmt.Sprintf("CREATE ROLE %s", role.Name)
	log.Debug(query)
	_, err := db.Conn.Exec(query)
	return err
}
