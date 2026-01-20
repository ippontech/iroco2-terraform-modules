package postgres

import (
	"fmt"
	"strings"

	"github.com/lib/pq"
	log "github.com/sirupsen/logrus"
	types "github.com/ippontech/iroco2-terraform-modules/modules/lambdas/iroco2-rds-db-provisioner/src/internal/types"
)

func (db *PostgresService) CreateAutoGrant(g types.AutoGrant) error {
	privilegeStr := strings.Join(g.Privileges, ", ")

	// Schema clause is optional when altering default privileges
	schemaStr := ""
	if g.Schema != "" {
		schemaStr = fmt.Sprintf("IN SCHEMA %s", pq.QuoteIdentifier(g.Schema))
	}

	query := fmt.Sprintf(
		"ALTER DEFAULT PRIVILEGES FOR ROLE %s %s GRANT %s ON %s TO %s;",
		pq.QuoteIdentifier(g.Owner),
		schemaStr,
		privilegeStr,
		g.ObjectType,
		pq.QuoteIdentifier(g.Grantee),
	)
	log.Debug(query)
	_, err := db.Conn.Exec(query)
	if err != nil {
		return err
	}
	return nil
}
