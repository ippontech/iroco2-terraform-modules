terraform {
  backend "s3" {
    key = "infrastructure/eu-west-3/services/terraform.tfstate"
  }
}
