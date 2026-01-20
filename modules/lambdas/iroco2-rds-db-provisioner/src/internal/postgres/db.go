package postgres

import (
	"database/sql"
	"fmt"

	"github.com/lib/pq"
	log "github.com/sirupsen/logrus"
	types "github.com/ippontech/iroco2-terraform-modules/modules/lambdas/iroco2-rds-db-provisioner/src/internal/types"
)

type PostgresService struct {
	Conn           *sql.DB
	ConnectionInfo *types.ConnectionInfo
}

func (db *PostgresService) Close() error {
	return db.Conn.Close()
}

func (db *PostgresService) GetConnectionInfo() types.ConnectionInfo {
	return *db.ConnectionInfo
}

func NewPostgresConnection(info *types.ConnectionInfo, dbname string) (*sql.DB, error) {
	log.Debugf("connecting to database '%s' with user '%s'", dbname, info.User)
	psqlInfo := fmt.Sprintf(
		"host=%s port=%d user=%s password=%s dbname=%s sslmode=%s",
		info.Host, info.Port, info.User, info.Password, dbname, info.SSLMode,
	)

	db, err := sql.Open("postgres", psqlInfo)
	if err != nil {
		return nil, err
	}

	err = db.Ping()
	if err != nil {
		return nil, err
	}

	return db, nil
}

func (db *PostgresService) CheckDatabaseExists(name string) (bool, error) {
	var exists bool
	query := fmt.Sprintf("SELECT EXISTS(SELECT 1 FROM pg_database WHERE datname = %s);", quoteLiteral(name))
	log.Debug(query)
	err := db.Conn.QueryRow(query).Scan(&exists)
	if err != nil {
		return false, err
	}
	return exists, nil
}

func (db *PostgresService) CreateDatabase(name string) error {
	query := fmt.Sprintf("CREATE DATABASE %s;", pq.QuoteIdentifier(name))
	log.Debug(query)
	_, err := db.Conn.Exec(query)
	return err
}

func (db *PostgresService) RevokeDatabaseDefaults(name string) error {
	query := fmt.Sprintf("REVOKE CONNECT ON DATABASE %s FROM PUBLIC;", pq.QuoteIdentifier(name))
	_, err := db.Conn.Exec(query)
	return err
}
