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
resource "random_password" "rds_master_pass" {
  length           = 40
  special          = true
  min_special      = 5
  override_special = "!#$%^&*()-_=+[]{}<>:?"

  lifecycle {
    ignore_changes = [
      override_special,
      min_special
    ]
  }
}

# The secret
resource "aws_secretsmanager_secret" "rds_master_pass" {
  name = "${var.namespace}/${var.environment}/rds/master-password-irocalc-db-secret"
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
