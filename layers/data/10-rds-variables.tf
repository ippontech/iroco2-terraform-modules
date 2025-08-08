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

variable "rds_instance_class" {
  type        = string
  description = "The instance class to use for the RDS."
}

variable "rds_database_engine" {
  type        = string
  description = "The engine to use for the RDS."
}

variable "rds_database_engine_version" {
  type        = string
  description = "The engine's version to use for the RDS."
}

variable "rds_allocated_storage" {
  type        = string
  description = "The size allocated for the storage."
}

variable "rds_backup_retention_period" {
  type        = string
  description = "The time a backup will be available."
}

variable "rds_is_multi_az" {
  type        = bool
  description = "Set to true if the RDS should be on multiple az."
}

variable "rds_database_port" {
  type        = number
  description = "The port to use for the RDS."
}

variable "rds_database_name" {
  type        = string
  description = "RDS's name"
}
