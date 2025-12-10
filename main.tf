module "network" {
  source = "./modules/network"

  project_name = "network"
  environment  = var.environment
  aws_region   = var.aws_region

  cidr             = var.cidr
  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  database_subnets = var.database_subnets
  subdomain_name   = var.subdomain_name
  zone_name        = var.zone_name
}

module "services" {
  source = "./modules/services"

  project_name = "services"
  environment  = var.environment

  container_insight_setting_value = var.container_insight_setting_value
  capacity_provider               = var.capacity_provider
  subdomain_name                  = var.subdomain_name
  zone_name                       = var.zone_name
  email_addresses                 = var.email_addresses

  providers = {
    aws            = aws
    aws.cloudfront = aws.cloudfront
  }
}
