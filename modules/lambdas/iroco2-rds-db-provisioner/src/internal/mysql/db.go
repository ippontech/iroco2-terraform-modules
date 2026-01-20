package mysql

import (
	"database/sql"
	"fmt"

	log "github.com/sirupsen/logrus"
	types "github.com/ippontech/iroco2-terraform-modules/modules/lambdas/iroco2-rds-db-provisioner/src/internal/types"

	_ "github.com/go-sql-driver/mysql" // MySQL driver
)

type MysqlService struct {
	Conn           *sql.DB
	ConnectionInfo *types.ConnectionInfo
}

func (db *MysqlService) Close() error {
	return db.Conn.Close()
}

func (db *MysqlService) GetConnectionInfo() types.ConnectionInfo {
	return *db.ConnectionInfo
}

func NewMySQLConnection(info *types.ConnectionInfo, dbname string) (*sql.DB, error) {
	log.Printf("connecting to database '%s' with user '%s'", dbname, info.User)

	// Format: user:password@tcp(host:port)/dbname?tls=...
	dsn := fmt.Sprintf(
		"%s:%s@tcp(%s:%d)/%s?parseTime=true&tls=%s",
		info.User, info.Password, info.Host, info.Port, dbname, info.SSLMode,
	)

	db, err := sql.Open("mysql", dsn)
	if err != nil {
		return nil, err
	}

	err = db.Ping()
	if err != nil {
		return nil, err
	}

	return db, nil
}

func (db *MysqlService) CheckDatabaseExists(name string) (bool, error) {
	query := "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = ?;"
	log.Debug(query)
	var schemaName string
	err := db.Conn.QueryRow(query, name).Scan(&schemaName)
	if err == sql.ErrNoRows {
		return false, nil
	}
	if err != nil {
		return false, err
	}
	return schemaName == name, nil
}

func (db *MysqlService) CreateDatabase(name string) error {
	query := fmt.Sprintf("CREATE DATABASE `%s`;", name)
	log.Debug(query)
	_, err := db.Conn.Exec(query)
	return err
}

func (db *MysqlService) RevokeDatabaseDefaults(name string) error {
	log.Warn("MySQL does not support REVOKE CONNECT statements. No action taken.")
	return nil
}
