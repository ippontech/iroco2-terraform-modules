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

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = false
}
