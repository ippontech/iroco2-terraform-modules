module "network" {
  source = "./modules/network"

  project_name = "network"
  environment  = var.environment
  aws_region   = var.aws_region

  cidr                 = var.cidr
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  database_subnets     = var.database_subnets
  subdomain_name       = var.subdomain_name
  zone_name            = var.zone_name
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  create_vpc_endpoints = var.create_vpc_endpoints
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
  up_recurrence             = var.up_recurrence
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

  depends_on = [module.network]
}

module "lambda_cur" {
  source = "./modules/lambdas/iroco2-cur-analyzer"

  environment       = var.environment
  project_name      = "cur"
  front_domain_name = "${var.subdomain_name}.${var.zone_name}"
}

module "backend_api" {
  source = "./modules/fargate-task"

  # Global variables
  aws_region        = var.aws_region
  project_name      = "irocalc-backend"
  environment       = var.environment
  cur_s3_bucket_arn = module.lambda_cur.s3_cur_bucket_arn

  # Network variables
  vpc_id                = module.network.vpc_id
  private_subnet_ids    = module.network.private_subnet_ids
  alb_dns_name          = module.network.alb_dns_name
  alb_zone_id           = module.network.alb_zone_id
  alb_arn_suffix        = module.network.alb_arn_suffix
  alb_listener_arn      = module.network.alb_listener_https_arn
  alb_security_group_id = module.network.security_group_ids["iroco2-${var.environment}-alb"]
  subdomain_name        = var.subdomain_name
  zone_name             = var.zone_name

  # ECS variables
  cluster_name                  = module.services.cluster.name
  cluster_id                    = module.services.cluster.id
  container_cpu                 = var.container_cpu
  container_memory              = var.container_memory
  container_port                = var.container_port
  container_image               = var.container_image
  container_desired_count       = var.container_desired_count
  kms_identity_key_arn          = data.aws_kms_key.signing_key.arn
  ecs_backend_security_group_id = module.network.security_group_ids["iroco2-${var.environment}-iroco-backend"]

  task_container_environment = {
    DATABASE_NAME                      = module.data.rds_database.db_instance_name
    IROCO2_CORS_ALLOWED_ORIGINS        = var.cors_allowed_origins
    IROCO2_AWS_ANALYZER_SQS_QUEUE_NAME = module.lambda_cur.analyzer_sqs_cur_name
    IROCO2_AWS_SCANNER_SQS_QUEUE_NAME  = module.lambda_cur.scanner_sqs_cur_name
    IROCO2_AWS_SQS_QUEUE_ENDPOINT      = trimsuffix(module.lambda_cur.analyzer_sqs_cur_url, module.lambda_cur.analyzer_sqs_cur_name)
    S3_BUCKET_NAME                     = module.lambda_cur.s3_cur_bucket_id
    IROCO2_AWS_REGION_STATIC           = var.aws_region
    IROCO2_CLERK_ISSUER                = module.services.ssm_parameters["clerk_issuer"].value
    IROCO2_CLERK_AUDIENCE              = module.services.ssm_parameters["clerk_audience"].value
    IROCO2_CLERK_PUBLIC_KEY            = module.services.ssm_parameters["clerk_public_key"].value
    IROCO2_KMS_IDENTITY_KEY_ID         = module.data.iroco_identity_provider_key_id.id
    IROCO2_KMS_IDENTITY_PUBLIC_KEY     = data.aws_kms_public_key.by_id.public_key
    JWT_ISSUER                         = var.zone_name
    JWT_AUDIENCE                       = var.zone_name
  }
  task_container_secrets_arn = {}
  task_container_secrets_arn_with_key = {
    IROCO2_DATA_SOURCE_URL = {
      arn = module.data.rds_database_secret_arn
      key = "host"
    }
    IROCO2_DATA_SOURCE_USERNAME = {
      arn = module.data.rds_database_secret_arn
      key = "username"
    }
    IROCO2_DATA_SOURCE_PASSWORD = {
      arn = module.data.rds_database_secret_arn
      key = "password"
    }
    IROCO2_DATA_SOURCE_FLYWAY_USERNAME = {
      arn = module.data.rds_database_secret_arn
      key = "username"
    }
    IROCO2_DATA_SOURCE_FLYWAY_PASSWORD = {
      arn = module.data.rds_database_secret_arn
      key = "password"
    }
  }
}
