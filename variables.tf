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

## ---------------------- GLOBAL -------------------------------
variable "namespace" {
  type        = string
  description = "The namespace in which the project is."
  default     = "iroco2"
}

variable "environment" {
  type        = string
  description = "The name of the environment we are deploying to"
}

variable "aws_region" {
  type        = string
  description = "The AWS region to deploy to (already in backend config but we need it for null resource)"
}

variable "project_type" {
  type        = string
  description = "The type of project."
  default     = "infrastructure"
}

## ---------------------- NETWORK ------------------------------
variable "cidr" {
  description = "The IPv4 CIDR block for the VPC."
  type        = string
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
}

variable "database_subnets" {
  description = "A list of database subnets"
  type        = list(string)
}

variable "zone_name" {
  type        = string
  description = "The zone associated to this environment. Example : test.yourdomain.com"
}

variable "subdomain_name" {
  type        = string
  description = "The subdomain that will be prefixed to the zone name to create the final domain name. Example : `iroco2` => iroco2.test.yourdomain.com"
}

variable "cors_allowed_origins" {
  type        = string
  description = "List of allowed origins for CORS"
}

# Whether to create VPC endpoints (Interface endpoints) in the VPC. We recommend to use NAT Gateway by default.
# Our VPC endpoints setup is using SSM documents in order to be:
# - Better FinOps, as it's cheaper than a NAT Gateway (when scheduled for work hours)
# - Better security, as it's using private endpoints instead of public ones
# But be careful, SSM documents deploying VPC endpoints means:
# - Trigger manually the SSM document to create VPC endpoints the first time you deploy the stack, or wait for the first time the SSM document is triggered by the schedule
# - Be sure to have an ECR repository with the images for backend service + keycloak
variable "create_vpc_endpoints" {
  description = "Controls if VPC Endpoints configuration should be created"
  type        = bool
}

## ---------------------- SERVICES ------------------------------
variable "container_insight_setting_value" {
  type        = string
  description = "Container insight value."
}

variable "capacity_provider" {
  type        = string
  description = "Capacity of the provider"
}

variable "email_addresses" {
  default     = []
  type        = list(string)
  description = "List of email addresses to be used by SES to send emails to Iroco's responsibles"
}

## ---------------------- DATA ------------------------------
variable "rds_instance_name" {
  type        = string
  description = "The AWS RDS DB instance name for irocalc."
}

variable "rds_deletion_protection" {
  type        = bool
  description = "If the RDS instance should have deletion protection enabled."
}

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

variable "create_bastion" {
  type        = bool
  description = "If the bastion should be created."
}

variable "instance_type" {
  default     = "t3a.nano"
  type        = string
  description = "The instance type for the bastion."
}

variable "bastion_volume_size" {
  type        = number
  description = "disk volume size for asg bastion instances"
  default     = 10
}

variable "down_recurrence" {
  type        = string
  description = "Down Recurrence"
}

variable "up_recurrence" {
  type        = string
  description = "Up Recurrence"
}

## ---------------------- ECS TASK ------------------------------
variable "container_cpu" {
  type        = number
  description = "The number of CPU units to reserve for the container"
}

variable "container_memory" {
  type        = number
  description = "The amount of memory to reserve for the container"
}

variable "container_image" {
  type        = string
  description = "The image to use for the container"
}

variable "container_port" {
  type    = number
  default = 8080

  validation {
    condition     = var.container_port > 0 && var.container_port <= 65536
    error_message = "The port should be between 0 and 65536."
  }
}

variable "container_desired_count" {
  type    = number
  default = 1

  validation {
    condition     = var.container_desired_count >= 1
    error_message = "You should have at least one instance running."
  }
}
