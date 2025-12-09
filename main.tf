module "network" {
  source = "./modules/network"

  environment = var.environment
  aws_region  = var.aws_region

  cidr             = var.cidr
  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  database_subnets = var.database_subnets
  subdomain_name   = var.subdomain_name
  zone_name        = var.zone_name
}
