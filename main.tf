module "iroco2-network" {
  source = "./modules/iroco2-network"

  environment      = var.environment
  domain_name      = var.domain_name
  cidr             = var.cidr
  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  database_subnets = var.database_subnets
}
