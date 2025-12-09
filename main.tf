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

module "services" {
  source = "./modules/services"

  environment = var.environment
  aws_region  = var.aws_region

  container_insight_setting_value = var.container_insight_setting_value
  capacity_provider               = var.capacity_provider
  subdomain_name                  = var.subdomain_name
  zone_name                       = var.zone_name
  email_addresses                 = var.email_addresses
}
