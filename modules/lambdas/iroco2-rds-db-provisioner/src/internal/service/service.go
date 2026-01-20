package service

import (
	"fmt"

	log "github.com/sirupsen/logrus"
	"github.com/ippontech/iroco2-terraform-modules/modules/lambdas/iroco2-rds-db-provisioner/src/internal/mysql"
	"github.com/ippontech/iroco2-terraform-modules/modules/lambdas/iroco2-rds-db-provisioner/src/internal/postgres"
	types "github.com/ippontech/iroco2-terraform-modules/modules/lambdas/iroco2-rds-db-provisioner/src/internal/types"
)

type DatabaseEngine interface {
	CheckDatabaseExists(name string) (bool, error)
	UpdateRoles(user types.User) error
	UpdateUserAuth(user types.User, password string) error
	CreateUser(user types.User) error
	CheckUserExists(user types.User) (bool, error)
	CreateRole(role types.Role) error
	CheckRoleExists(role types.Role) (bool, error)
	RevokeDatabaseDefaults(name string) error
	CreateDatabase(name string) error
	CreateAutoGrant(autogrant types.AutoGrant) error
	AlterSchemaOwner(schema types.Schema) error
	CreateSchema(schema types.Schema) error
	CheckSchemaExists(schema types.Schema) (bool, error)
	CreateGrant(grant types.Grant) error

	GetConnectionInfo() types.ConnectionInfo
	Close() error
}

type DatabaseService struct {
	Engine DatabaseEngine
}

func NewDatabaseConnection(info types.ConnectionInfo, database string) (*DatabaseService, error) {
	var engine DatabaseEngine

	log.Infof("initializing database connection with host %s", info.Host)

	switch info.Driver {
	case "postgres":
		conn, err := postgres.NewPostgresConnection(&info, database)
		if err != nil {
			log.Errorf("failed to connect to database %s", database)
			return nil, err
		}
		engine = &postgres.PostgresService{Conn: conn, ConnectionInfo: &info}

	case "mysql":
		conn, err := mysql.NewMySQLConnection(&info, database)
		if err != nil {
			log.Errorf("failed to connect to database %s", database)
			return nil, err
		}
		engine = &mysql.MysqlService{Conn: conn, ConnectionInfo: &info}

	default:
		return nil, fmt.Errorf("upsupported database driver: %s", info.Driver)
	}

	return &DatabaseService{Engine: engine}, nil
}

func (db *DatabaseService) HandleAutoGrantRequest(g types.AutoGrant) error {
	// Connect to target db, default privileges are db scoped
	connInfo := db.Engine.GetConnectionInfo()
	newConn, err := NewDatabaseConnection(connInfo, g.Database)
	if err != nil {
		return err
	}
	defer newConn.Engine.Close()

	err = newConn.Engine.CreateAutoGrant(g)
	if err != nil {
		return err
	}
	return nil
}

func (db *DatabaseService) HandleDatabaseRequest(name string) error {
	exists, err := db.Engine.CheckDatabaseExists(name)
	if err != nil {
		return err
	}

	if exists {
		log.Infof("Database '%s' already exists, skipping creation.", name)
	} else {
		log.Infof("Creating database '%s'", name)
		err := db.Engine.CreateDatabase(name)
		if err != nil {
			return err
		}
	}

	err = db.Engine.RevokeDatabaseDefaults(name)
	return err
}

func (db *DatabaseService) HandleGrantRequest(g types.Grant) error {
	// Grants are database scoped, ensure connection to correct db
	connInfo := db.Engine.GetConnectionInfo()
	newConn, err := NewDatabaseConnection(connInfo, g.Database)
	if err != nil {
		return err
	}
	defer newConn.Engine.Close()

	err = newConn.Engine.CreateGrant(g)
	if err != nil {
		return err
	}
	return nil
}

func (db *DatabaseService) HandleRoleRequest(role types.Role) error {
	exists, err := db.Engine.CheckRoleExists(role)
	if err != nil {
		return nil
	}
	if exists {
		log.Infof("Role '%s' already exists, skipping creation.", role.Name)
		return nil
	} else {
		err := db.Engine.CreateRole(role)
		return err
	}
}

func (db *DatabaseService) HandleSchemaRequest(s types.Schema) error {
	// Schemas are database scoped, ensure connection to db
	connInfo := db.Engine.GetConnectionInfo()
	newConn, err := NewDatabaseConnection(connInfo, s.Database)
	if err != nil {
		return err
	}
	defer newConn.Engine.Close()

	exists, err := newConn.Engine.CheckSchemaExists(s)
	if err != nil {
		return nil
	}
	if exists {
		log.Infof("schema '%s' already exists, skipping creation", s.Name)
	} else {
		err := newConn.Engine.CreateSchema(s)
		if err != nil {
			return err
		}
	}

	err = newConn.Engine.AlterSchemaOwner(s)
	return err
}

func (db *DatabaseService) HandleUserRequest(user types.User, password string) error {
	exists, err := db.Engine.CheckUserExists(user)
	if err != nil {
		return err
	}
	if exists {
		log.Infof("User '%s' already exists, skipping creation", user.Name)
	} else {
		log.Infof("User '%s' does not exist, creating", user.Name)
		err := db.Engine.CreateUser(user)
		if err != nil {
			return err
		}
	}

	err = db.Engine.UpdateUserAuth(user, password)
	if err != nil {
		return err
	}

	err = db.Engine.UpdateRoles(user)
	if err != nil {
		log.Error("failed to grant roles to user")
		return err
	}
	return nil
}
