package postgres

import (
	"fmt"

	"github.com/lib/pq"
	log "github.com/sirupsen/logrus"
	types "github.com/ippontech/iroco2-terraform-modules/modules/lambdas/iroco2-rds-db-provisioner/src/internal/types"
)

func (db *PostgresService) CheckSchemaExists(s types.Schema) (bool, error) {
	var exists bool
	query := fmt.Sprintf(
		"SELECT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = %s);",
		quoteLiteral(s.Name),
	)
	log.Debug(query)
	err := db.Conn.QueryRow(query).Scan(&exists)
	if err != nil {
		log.Error("error while checking if schema exists")
		return false, err
	}
	return exists, nil
}

func (db *PostgresService) CreateSchema(s types.Schema) error {
	query := fmt.Sprintf("CREATE SCHEMA %s;", pq.QuoteIdentifier(s.Name))
	log.Debug(query)
	_, err := db.Conn.Exec(query)
	return err
}

func (db *PostgresService) AlterSchemaOwner(s types.Schema) error {
	query := fmt.Sprintf(
		"ALTER SCHEMA %s OWNER TO %s;",
		pq.QuoteIdentifier(s.Name),
		pq.QuoteIdentifier(s.Owner),
	)
	log.Debug(query)
	_, err := db.Conn.Exec(query)
	return err
}
