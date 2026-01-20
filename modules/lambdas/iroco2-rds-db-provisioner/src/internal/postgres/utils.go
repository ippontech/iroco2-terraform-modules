package postgres

import (
	"strings"

	"github.com/lib/pq"
)


func quoteLiteral(s string) string {
	escaped := strings.ReplaceAll(s, "'", "''")
	return "'" + escaped + "'"
}

func quoteCompositeIdentifier(ident string) string {
	parts := strings.Split(ident, ".")
	for i := range parts {
		parts[i] = pq.QuoteIdentifier(parts[i])
	}
	return strings.Join(parts, ".")
}
