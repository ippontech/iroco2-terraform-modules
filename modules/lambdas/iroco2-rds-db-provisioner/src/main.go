package main

import (
	"context"
	"os"

	log "github.com/sirupsen/logrus"
	"github.com/ippontech/iroco2-terraform-modules/modules/lambdas/iroco2-rds-db-provisioner/src/internal/handlers"
)

func main() {
	ctx := context.Background()
	log.SetLevel(log.DebugLevel)
	data, err := os.ReadFile("example-pg.json")
	if err != nil {
		panic(err)
	}

	err = handlers.LambdaHandler(ctx, data)
	if err != nil {
		log.Errorf("error during handler execution %v", err)
	}
}
