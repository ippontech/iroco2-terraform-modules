package mysql


import (
	"strings"
)


func quoteLiteral(s string) string {
	escaped := strings.ReplaceAll(s, "'", "''")
	return "'" + escaped + "'"
}
