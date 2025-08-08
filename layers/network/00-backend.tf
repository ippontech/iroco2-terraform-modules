terraform {
  backend "s3" {
    key = "infrastructure/eu-west-3/network/terraform.tfstate"
  }
}
