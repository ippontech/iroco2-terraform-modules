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

output "iroco_identity_provider_key_id" {
  value       = aws_kms_alias.alias
  description = "The key id of the identity provider"
}

output "rds_database" {
  value = {
    db_instance_arn      = module.rds.db_instance_arn
    db_instance_endpoint = module.rds.db_instance_endpoint
    db_instance_name     = module.rds.db_instance_name
    db_instance_port     = module.rds.db_instance_port
  }
  description = "The RDS database informations"
}

output "rds_database_secret_arn" {
  value       = aws_secretsmanager_secret.rds_master_pass.arn
  description = "The ARN of the secret containing the RDS master password"
}
