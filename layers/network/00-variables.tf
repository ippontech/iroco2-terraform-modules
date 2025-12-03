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

##################### METADATA #####################
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

variable "project_name" {
  type        = string
  description = "Project's name"
  default     = "network"
}

variable "project_type" {
  type        = string
  description = "The type of project."
  default     = "infrastructure"
}

variable "zone_name" {
  type        = string
  description = "The zone associated to this environment. Example : test.yourdomain.com"
}

variable "subdomain_name" {
  type        = string
  description = "The subdomain that will be prefixed to the zone name to create the final domain name. Example : `iroco2` => iroco2.test.yourdomain.com"
}
