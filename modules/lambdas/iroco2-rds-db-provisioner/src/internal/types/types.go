package postgres

import (
	"fmt"
	"slices"
	"strings"

	log "github.com/sirupsen/logrus"
)

type Schema struct {
	Database string `json:"database"`
	Name     string `json:"name"`
	Owner    string `json:"owner"`
}

type Role struct {
	Name string `json:"name"`
}

type User struct {
	Name     string   `json:"name"`
	Password string   `json:"password,omitempty"`  // When using plaintext passwords (unit tests)
	PasswordArn string `json:"password_arn,omitempty"`  // When using lambda
	Roles    []string `json:"roles"`
	Host string `json:"host,omitempty"`  // Required only for MySQL
}

type Grant struct {
	ObjectType string   `json:"object_type"`
	GrantTo    string   `json:"grant_to"`
	Target     string   `json:"target"`
	Privileges []string `json:"privileges"`
	Database   string   `json:"database"`
}

type AutoGrant struct {
	Owner      string   `json:"created_by"`
	ObjectType string   `json:"object_type"`
	Schema     string   `json:"schema,omitempty"`
	Privileges []string `json:"privileges"`
	Grantee    string   `json:"grant_to"`
	Database   string   `json:"database"`
}

type ConnectionInfo struct {
	Host     string
	Port     int
	User     string
	Password string
	SSLMode  string
	Driver string
	DefaultDatabase string
	SecretsProvider string
}

type Handler interface {
	CreateDB(name string) error
	CreateUser(name string, password string, iamAuth bool) error
}

var PostgresAutograntPrivilegeMapping = map[string][]string{
	"TABLES":    {"SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES", "TRIGGER"},
	"SEQUENCES": {"USAGE", "SELECT", "UPDATE"},
	"FUNCTIONS": {"EXECUTE"},
}

var PostgresAutograntObjectTypes = []string{"TABLES", "SEQUENCES", "FUNCTIONS"}

var PostgresGrantPrivilegeMapping = map[string][]string{
	"DATABASE": {"CONNECT", "CREATE", "TEMPORARY"},
	"SCHEMA":   {"CREATE", "USAGE"},
	"TABLE":    {"SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES", "TRIGGER"},
	"SEQUENCE": {"USAGE", "SELECT", "UPDATE"},
	"FUNCTION": {"EXECUTE"},
}

var PostgresGrantObjectTypes = []string{"DATABASE", "SCHEMA", "TABLE", "SEQUENCE", "FUNCTION"}


var MysqlGrantPrivilegeMapping = map[string][]string{
	"": {  // Privileges that can be set globally
		"ALL PRIVILEGES", "USAGE", "CREATE USER", "RELOAD",
		"SHUTDOWN", "PROCESS", "FILE", "GRANT OPTION", "SUPER",
		"REPLICATION CLIENT", "REPLICATION SLAVE", "BINLOG ADMIN",
	},

	"DATABASE": {
		"CREATE", "DROP", "GRANT OPTION", "REFERENCES",
		"EVENT", "ALTER", "CREATE TEMPORARY TABLES",
		"LOCK TABLES", "CREATE VIEW", "SHOW VIEW",
		"TRIGGER", "EXECUTE",
	},

	"TABLE": {
		"SELECT", "INSERT", "UPDATE", "DELETE",
		"CREATE", "DROP", "GRANT OPTION", "REFERENCES",
		"INDEX", "ALTER", "TRIGGER",
	},

	"COLUMN": {
		"SELECT", "INSERT", "UPDATE",
	},

	"PROCEDURE": {
		"EXECUTE", "ALTER ROUTINE", "GRANT OPTION",
	},

	"FUNCTION": {
		"EXECUTE", "ALTER ROUTINE", "GRANT OPTION",
	},
}

var MysqlGrantObjectTypes = []string{"", "DATABASE", "TABLE", "COLUMN", "PROCEDURE", "FUNCTION"}


/////////////
// Struct validation
/////////////

func (s Schema) Validate() error {
	var missing []string

	if s.Name == "" {
		missing = append(missing, "name")
	}
	if s.Database == "" {
		missing = append(missing, "database")
	}
	if s.Owner == "" {
		missing = append(missing, "owner")
	}

	if len(missing) > 0 {
		return fmt.Errorf("missing required fields in schema: %s", strings.Join(missing, ", "))
	}
	return nil
}

func (r Role) Validate() error {
	if r.Name == "" {
		return fmt.Errorf("field 'name' cannot be empty")
	}
	return nil
}

func (u User) Validate() error {
	if u.Name == "" {
		return fmt.Errorf("field 'name' cannot be empty")
	}
	return nil
}

func (g *Grant) Validate(engine string) error {
	var missing []string

	if g.GrantTo == "" {
		missing = append(missing, "grant_to")
	}
	if g.Database == "" {
		missing = append(missing, "database")
	}
	if g.Target == "" {
		missing = append(missing, "target")
	}
	if g.ObjectType == "" && engine != "mysql" {  // allow empty string in mysql for global privileges
		missing = append(missing, "object_type")
	}

	if len(missing) > 0 {
		return fmt.Errorf("missing required fields in grant: %v", strings.Join(missing, ", "))
	}

	if len(g.Privileges) == 0 {
		return fmt.Errorf("at least one privilege must be specified")
	}

	// Validate correct privilege usage based on engine
	var privilegeMapping map[string][]string
	var grantObjectTypes []string

	switch engine {
	case "postgres":
		privilegeMapping = PostgresGrantPrivilegeMapping
		grantObjectTypes = PostgresGrantObjectTypes
	case "mysql":
		privilegeMapping = MysqlGrantPrivilegeMapping
		grantObjectTypes = MysqlGrantObjectTypes
	default:
		return fmt.Errorf("unsupported engine: %s", engine)
	}

	if !slices.Contains(grantObjectTypes, g.ObjectType) {
		allowed := strings.Join(grantObjectTypes, ", ")
		return fmt.Errorf(
			"invalid object type '%s' for grant. Value must be one of: %s",
			g.ObjectType, allowed,
		)
	}

	err := validatePrivileges(g.ObjectType, g.Privileges, privilegeMapping)
	if err != nil {
		return err
	}

	return nil
}

func (g *AutoGrant) Validate(engine string) error {
	if engine == "mysql" {
		log.Debug("default privileges are not supported in mysql, skipping autogrant validation")
		return nil
	}
	var missing []string

	if g.Owner == "" {
		missing = append(missing, "created_by")
	}
	if g.Database == "" {
		missing = append(missing, "database")
	}
	if g.Grantee == "" {
		missing = append(missing, "grant_to")
	}
	if g.ObjectType == "" {
		missing = append(missing, "object_type")
	}

	if len(missing) > 0 {
		return fmt.Errorf("missing required fields in autogrant: %v", strings.Join(missing, ", "))
	}

	if len(g.Privileges) == 0 {
		return fmt.Errorf("at least one privilege must be specified")
	}

	// Validate correct privilege usage based on engine
	var privilegeMapping map[string][]string
	var grantObjectTypes []string

	switch engine {
	case "postgres":
		privilegeMapping = PostgresAutograntPrivilegeMapping
		grantObjectTypes = PostgresAutograntObjectTypes
	default:
		return fmt.Errorf("unsupported engine: %s", engine)
	}

	if !slices.Contains(grantObjectTypes, g.ObjectType) {
		allowed := strings.Join(grantObjectTypes, ", ")
		return fmt.Errorf(
			"invalid object type '%s' for grant. Value must be one of: %s",
			g.ObjectType, allowed,
		)
	}

	err := validatePrivileges(g.ObjectType, g.Privileges, privilegeMapping)
	if err != nil {
		return err
	}

	if len(g.Privileges) == 0 {
		return fmt.Errorf("at least one privilege must be specified")
	}
	return nil
}

func validatePrivileges(objectType string, privileges []string, privilegeMapping map[string][]string) error {
	allowedPrivileges := privilegeMapping[objectType]
	for _, p := range privileges {
		if !slices.Contains(allowedPrivileges, p) {
			return fmt.Errorf(
				"requested privilege '%s' is incompatible with object type '%s'",
				p, objectType,
			)
		}
	}
	return nil
}
