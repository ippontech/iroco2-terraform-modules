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

##### COMMON ####
variable "project_name" {
  type        = string
  description = "Project's name"
}

variable "environment" {
  type        = string
  description = "The environment to deploy to"
}

variable "namespace" {
  type        = string
  description = "The namespace in which the project is."
  default     = "iroco2"
}

variable "aws_region" {
  type        = string
  description = "The AWS region to deploy to"
}

variable "failover_mailing_list" {
  type        = list(string)
  description = "The mailing list to send alerts to"
  default = [
    # TODO: Add developers email after testing
  ]
}

variable "cur_s3_bucket_arn" {
  type        = string
  description = "The ARN of the S3 bucket where the CUR is stored"
}

variable "kms_identity_key_arn" {
  type        = string
  description = "The key arn of the kms key used for identity"
}

#### ECS ####
variable "cluster_name" {
  type        = string
  description = "The name of the ECS cluster"
}

variable "cluster_id" {
  type        = string
  description = "The ID of the ECS cluster"
}

#### NETWORK ####
variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "The private subnets ids."
}

variable "alb_security_group_id" {
  type        = string
  description = "The security group id of the ALB"
}

variable "ecs_backend_security_group_id" {
  type        = string
  description = "The security group id of the ECS backend"
}

variable "zone_name" {
  type        = string
  description = "The zone associated to this environment. Example : test.yourdomain.com"
}

variable "subdomain_name" {
  type        = string
  description = "The subdomain that will be prefixed to the zone name to create the final domain name. Example : `iroco2` => iroco2.test.yourdomain.com"
}

variable "alb_dns_name" {
  type        = string
  description = "ALB DNS name"
}

variable "alb_zone_id" {
  type        = string
  description = "ALB zone ID"
}

variable "alb_arn_suffix" {
  type        = string
  description = "ALB ARN suffix"
}

variable "alb_listener_arn" {
  type        = string
  description = "ALB listener ARN"
}

#### CONTAINER ####
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

#### APP SPECIFICS ####
variable "task_container_environment" {
  type        = map(string)
  description = "The environment variables to pass to the container"
  default     = {}
}

variable "task_container_secrets_arn" {
  type        = map(string)
  description = "The secrets to pass to the container"
  default     = {}
}

variable "task_container_secrets_arn_with_key" {
  type = map(object({
    arn = string
    key = string
  }))
  description = "The secrets to pass to the container"
  default     = {}
}
