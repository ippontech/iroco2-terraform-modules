terraform {
  backend "s3" {
    key = "infrastructure/eu-west-3/data/terraform.tfstate"
  }
}
