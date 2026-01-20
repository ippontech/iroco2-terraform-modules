package mysql

import (
	"testing"

	sqlmock "github.com/DATA-DOG/go-sqlmock"
	types "github.com/ippontech/iroco2-terraform-modules/modules/lambdas/iroco2-rds-db-provisioner/src/internal/types"
)

func TestCreateUserQuery(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("failed to open sqlmock: %v", err)
	}
	defer db.Close()

	service := &MysqlService{Conn: db}
	user := types.User{Name: "testuser", Host: "localhost", Password: "secret"}

	mock.ExpectExec("CREATE USER 'testuser'@'localhost'").WillReturnResult(sqlmock.NewResult(1, 1))
	mock.ExpectExec("ALTER USER 'testuser'@'localhost' IDENTIFIED BY 'secret'").WillReturnResult(sqlmock.NewResult(1, 1))

	err = service.CreateUser(user)
	if err != nil {
		t.Errorf("unexpected error: %v", err)
	}
	err = service.UpdateUserAuth(user, user.Password)
	if err != nil {
		t.Errorf("unexpected error: %v", err)
	}

	if err := mock.ExpectationsWereMet(); err != nil {
		t.Errorf("there were unfulfilled expectations: %v", err)
	}
}
