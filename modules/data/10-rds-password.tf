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

# Initial password
ephemeral "random_password" "rds_master_pass" {
  length  = 40
  special = false
}

# The secret
resource "aws_secretsmanager_secret" "rds_master_pass" {
  name = "${var.namespace}/${var.environment}/rds/master-password-irocalc-db-secret"

  tags = {
    project = var.project_name
  }
}

# Initial version
resource "aws_secretsmanager_secret_version" "rds_master_pass" {
  secret_id                = aws_secretsmanager_secret.rds_master_pass.id
  secret_string_wo_version = 1
  secret_string_wo = jsonencode(
    {
      username = var.rds_database_name
      password = ephemeral.random_password.rds_master_pass.result
    }
  )
}

ephemeral "aws_secretsmanager_secret_version" "rds_master_pass" {
  secret_id = aws_secretsmanager_secret_version.rds_master_pass.secret_id
}

# Password for Keycloak DB
ephemeral "random_password" "rds_keycloak_pass" {
  length           = 40
  special          = true
  min_special      = 5
  override_special = "!#$%^&*()-_=+[]{}<>:?"
}

# The secret for Keycloak DB
resource "aws_secretsmanager_secret" "rds_keycloak_pass" {
  name = "${var.namespace}/${var.environment}/rds/keycloak-db-secret"

  tags = {
    project = var.project_name
  }
}

# Initial version for Keycloak DB
resource "aws_secretsmanager_secret_version" "rds_keycloak_pass" {
  secret_id                = aws_secretsmanager_secret.rds_keycloak_pass.id
  secret_string_wo_version = 1
  secret_string_wo = jsonencode(
    {
      username = "keycloak"
      password = ephemeral.random_password.rds_keycloak_pass.result
    }
  )
}

# Password for Keycloak Admin
ephemeral "random_password" "rds_keycloak_admin_pass" {
  length           = 40
  special          = true
  min_special      = 5
  override_special = "!#$%^&*()-_=+[]{}<>:?"
}

# The secret for Keycloak Admin
resource "aws_secretsmanager_secret" "rds_keycloak_admin_pass" {
  name = "${var.namespace}/${var.environment}/rds/keycloak-admin-secret"

  tags = {
    project = var.project_name
  }
}

# Initial version for Keycloak Admin
resource "aws_secretsmanager_secret_version" "rds_keycloak_admin_pass" {
  secret_id                = aws_secretsmanager_secret.rds_keycloak_admin_pass.id
  secret_string_wo_version = 1
  secret_string_wo = jsonencode(
    {
      KEYCLOAK_ADMIN          = "keycloak-admin"
      KEYCLOAK_ADMIN_PASSWORD = ephemeral.random_password.rds_keycloak_admin_pass.result
    }
  )
}
