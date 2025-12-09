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

# Common
variable "namespace" {
  type        = string
  description = "The namespace in which the project is."
}

variable "SecurityGroupId" {
  type        = string
  description = "The id of the security group"
}

variable "SubnetIds" {
  type        = list(any)
  description = "List of subnet ids"
}

variable "vpc_id" {
  type        = string
  description = "The id of the VPC to use."
}

variable "RouteTableIds" {
  type        = list(string)
  description = "The list of route table Id"
}

# SSM
variable "environment" {
  type        = string
  description = "The name of the environment we are deploying to"
}

variable "tag_autoshutdown" {
  type        = string
  description = "Describe how the ressources is managed: True if a ssm document is applied to start and stop the ressource"
}

variable "endpoint" {
  type        = any
  description = "The endpoint we want to automate"
}

variable "ssm_document" {
  description = "SSM document's name to apply"
  type        = string
}

variable "working_days" {
  type        = list(string)
  description = "The list of working days"
}
