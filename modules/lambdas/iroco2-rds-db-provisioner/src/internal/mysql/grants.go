package mysql

import (
	"fmt"
	"strings"

	log "github.com/sirupsen/logrus"
	types "github.com/ippontech/iroco2-terraform-modules/modules/lambdas/iroco2-rds-db-provisioner/src/internal/types"
)

func (db *MysqlService) CreateGrant(g types.Grant) error {
	privilegeStr := strings.Join(g.Privileges, ", ")

	query := fmt.Sprintf(
		"GRANT %s ON %s %s TO %s;",
		privilegeStr,
		g.ObjectType,
		g.Target,
		g.GrantTo,
	)
	log.Debug(query)
	_, err := db.Conn.Exec(query)
	return err
}
