provider "aws" {
  region = "eu-west-3"

  default_tags {
    tags = {
      ManagedBy = "Terraform"
      Module    = "iroco2-client-side-scanner"
    }
  }
}
