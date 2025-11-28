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

variable "namespace" {
  type        = string
  description = "The namespace in which the project is."
  default     = "iroco2"
}

variable "environment" {
  type        = string
  description = "The name of the environment we are deploying to"
}

variable "project_name" {
  type        = string
  description = "Project's name"
  default     = "api-gateway-infrastructure"
}

variable "project_type" {
  type        = string
  description = "The type of project."
  default     = "application"
}

variable "aws_lambda_payload_cur_part_function_name" {
  description = "Name of the lambda (in the outputs of the payload-cur-part lambda repository)"
}

variable "aws_lambda_payload_cur_part_invoke_arn" {
  description = "Invoke ARN of the lambda (in the outputs of the payload-cur-part lambda repository)"
}
variable "tfstate_bucket" {
  type        = string
  description = "The tfstate bucket where to fetch some information from the other layers."
}
