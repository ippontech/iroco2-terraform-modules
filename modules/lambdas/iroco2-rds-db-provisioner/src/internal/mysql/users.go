package mysql

import (
	"fmt"

	log "github.com/sirupsen/logrus"
	types "github.com/ippontech/iroco2-terraform-modules/modules/lambdas/iroco2-rds-db-provisioner/src/internal/types"
)

func (db *MysqlService) CreateUser(user types.User) error {
	// TODO: add support for iam auth with clause: IDENTIFIED WITH AWSAuthenticationPlugin AS 'RDS'
	userIdentifier := fmt.Sprintf("'%s'@'%s'", user.Name, user.Host)
	query := fmt.Sprintf("CREATE USER %s;", userIdentifier)
	log.Debug(query)
	_, err := db.Conn.Exec(query)
	return err
}

func (db *MysqlService) UpdateUserAuth(user types.User, password string) error {
	// TODO: add iam auth
	if password == "" {
		log.Debug("no password specified, skipping user auth update")
		return nil
	}
	// TODO: check if setting password as empty string disables login or allows passwordless login instead
	// identifier format is: 'username'@'host'
	userIdentifier := fmt.Sprintf("'%s'@'%s'", user.Name, user.Host)
	query := fmt.Sprintf("ALTER USER %s IDENTIFIED BY %s;", userIdentifier, quoteLiteral(password))
	log.Debug(query)
	_, err := db.Conn.Exec(query)
	return err
}

func (db *MysqlService) UpdateRoles(user types.User) error {
	// identifier format is: 'username'@'host'
	userIdentifier := fmt.Sprintf("'%s'@'%s'", user.Name, user.Host)
	for _, r := range user.Roles {
		err := db.GrantRole(user, r)
		if err != nil {
			log.Errorf("failed to grant role %s to %s. %v", r, userIdentifier, err)
			return err
		}
	}
	return nil
}

func (db *MysqlService) GrantRole(user types.User, role string) error {
	// identifier format is: 'username'@'host'
	userIdentifier := fmt.Sprintf("'%s'@'%s'", user.Name, user.Host)
	query := fmt.Sprintf("GRANT %s TO %s;", role, userIdentifier)
	log.Debug(query)
	_, err := db.Conn.Exec(query)
	return err
}

func (db *MysqlService) CheckUserExists(user types.User) (bool, error) {
	var exists bool
	query := `SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = ? AND host = ?);`
	log.Debug(query)
	err := db.Conn.QueryRow(query, user.Name, user.Host).Scan(&exists)
	if err != nil {
		return false, err
	}
	return exists, nil
}
