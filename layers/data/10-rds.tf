# Copyright 2025 Ippon Technologies
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

locals {
  rds_db_identifier = "irocalc-${var.environment}-rds"
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "5.2.3"

  # General
  identifier = local.rds_db_identifier
  db_name    = var.rds_database_name

  engine               = var.rds_database_engine
  instance_class       = var.rds_instance_class
  engine_version       = var.rds_database_engine_version
  family               = "${var.rds_database_engine}${var.rds_database_engine_version}" # DB parameter group
  major_engine_version = var.rds_database_engine_version                                # DB option group
  multi_az             = var.rds_is_multi_az

  # Storage
  allocated_storage = var.rds_allocated_storage
  kms_key_id        = aws_kms_key.rds.arn
  storage_encrypted = true

  # Security
  username                            = var.namespace
  password                            = random_password.rds_master_pass.result
  iam_database_authentication_enabled = false
  create_random_password              = false

  # Network
  port                   = var.rds_database_port
  vpc_security_group_ids = [data.terraform_remote_state.network.outputs.security_group_ids["iroco_database"], aws_security_group.rds.id]
  subnet_ids             = data.terraform_remote_state.network.outputs.database_subnets_ids
  create_db_subnet_group = true

  # Maintenance
  # TODO: check if updates apply during offline hours
  maintenance_window          = "Mon:05:00-Mon:06:00"
  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false

  # Backup
  backup_window            = "12:45-13:15"
  backup_retention_period  = var.rds_backup_retention_period
  copy_tags_to_snapshot    = true
  delete_automated_backups = false

  # Logs
  enabled_cloudwatch_logs_exports = var.rds_database_engine == "postgres" ? ["postgresql", "upgrade"] : []
  create_cloudwatch_log_group     = true

  deletion_protection = true
  apply_immediately   = true

  parameters = var.rds_database_engine == "postgres" ? [{ name = "rds.force_ssl", value = "1" }] : []
}

# TODO: Remove this security group when we migrate to the new ones
resource "aws_security_group" "rds" {
  name   = "${var.rds_database_name}-rds"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  ingress {
    from_port   = var.rds_database_port
    to_port     = var.rds_database_port
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.128/26", "10.0.0.192/26"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
