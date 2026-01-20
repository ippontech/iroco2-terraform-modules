package mysql

import (
	"fmt"

	types "github.com/ippontech/iroco2-terraform-modules/modules/lambdas/iroco2-rds-db-provisioner/src/internal/types"
)

func (db *MysqlService) CheckSchemaExists(s types.Schema) (bool, error) {
	return false, fmt.Errorf("schemas are not supported in MySQL, skipping CheckSchemaExists")
}

func (db *MysqlService) CreateSchema(s types.Schema) error {
	return fmt.Errorf("schemas are not supported in MySQL, skipping CreateSchema")
}

func (db *MysqlService) AlterSchemaOwner(s types.Schema) error {
	return fmt.Errorf("schemas are not supported in MySQL, skipping AlterSchemaOwner")
}
