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

module "data" {
  source = "./modules/data"

  environment  = var.environment
  project_name = "data"

  create_bastion            = var.create_bastion
  down_recurrence           = var.down_recurrence
  private_subnet_ids        = module.network.private_subnet_ids
  bastion_security_group_id = module.network.security_group_ids["iroco2-${var.environment}-bastion"]

  rds_security_group_id       = module.network.security_group_ids["iroco2-${var.environment}-iroco-database"]
  rds_database_subnets_ids    = module.network.database_subnets_ids
  rds_instance_name           = var.rds_instance_name
  rds_instance_class          = var.rds_instance_class
  rds_allocated_storage       = var.rds_allocated_storage
  rds_database_name           = var.rds_database_name
  rds_database_port           = var.rds_database_port
  rds_database_engine         = var.rds_database_engine
  rds_database_engine_version = var.rds_database_engine_version
  rds_backup_retention_period = var.rds_backup_retention_period
  rds_deletion_protection     = var.rds_deletion_protection
  rds_is_multi_az             = var.rds_is_multi_az
}
