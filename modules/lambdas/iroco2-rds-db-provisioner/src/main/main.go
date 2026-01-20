package main

import (
	"github.com/aws/aws-lambda-go/lambda"

	"github.com/ippontech/iroco2-terraform-modules/modules/lambdas/iroco2-rds-db-provisioner/src/src/internal/handlers"
)

func main() {
	lambda.Start(handlers.LambdaHandler)
}
