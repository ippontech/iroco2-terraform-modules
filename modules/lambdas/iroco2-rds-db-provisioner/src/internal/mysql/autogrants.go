package mysql

import (
	"fmt"

	types "github.com/ippontech/iroco2-terraform-modules/modules/lambdas/iroco2-rds-db-provisioner/src/internal/types"
)

func (db *MysqlService) CreateAutoGrant(g types.AutoGrant) error {
	return fmt.Errorf("altering default privileges is NOT supported in MySQL, skipping autogrant creation")
}
