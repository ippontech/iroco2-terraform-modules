package postgres

import (
	"fmt"
	"strings"

	"github.com/lib/pq"
	log "github.com/sirupsen/logrus"
	types "github.com/ippontech/iroco2-terraform-modules/modules/lambdas/iroco2-rds-db-provisioner/src/internal/types"
)

func (db *PostgresService) CreateGrant(g types.Grant) error {
	privilegeStr := strings.Join(g.Privileges, ", ")
	query := fmt.Sprintf(
		"GRANT %s ON %s %s TO %s;",
		privilegeStr,
		g.ObjectType,
		quoteCompositeIdentifier(g.Target),
		pq.QuoteIdentifier(g.GrantTo),
	)
	log.Debug(query)
	_, err := db.Conn.Exec(query)
	return err
}
