# Initial password
resource "random_password" "rds_master_pass" {
  length           = 40
  special          = true
  min_special      = 5
  override_special = "!#$%^&*()-_=+[]{}<>:?"

  # TODO: Remove this after the next apply
  lifecycle {
    ignore_changes = [
      override_special,
      min_special
    ]
  }
}

# The secret
resource "aws_secretsmanager_secret" "rds_master_pass" {
  name = "/RDS/MASTER_PASSWORD_IROCALC_DB_SECRET"

  # TODO: test automatic rotation
}

# Initial version
resource "aws_secretsmanager_secret_version" "rds_master_pass" {
  secret_id = aws_secretsmanager_secret.rds_master_pass.id
  secret_string = jsonencode(
    {
      username = module.rds.db_instance_username
      password = module.rds.db_instance_password
      engine   = module.rds.db_instance_engine
      host     = module.rds.db_instance_endpoint
      jdbc_url = format("jdbc:postgresql://%s/%s", module.rds.db_instance_endpoint, var.rds_database_name)
    }
  )
}
