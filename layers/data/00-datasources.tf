data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    region = "eu-west-3"
    bucket = "iroco-tfstates-store-${var.environment}"
    key    = "infrastructure/eu-west-3/network/terraform.tfstate"
  }
}

data "aws_region" "current" {}
