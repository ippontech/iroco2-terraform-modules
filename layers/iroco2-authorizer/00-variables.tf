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
  default     = "authorizer"
}

variable "project_type" {
  type        = string
  description = "The type of project."
  default     = "application"
}

variable "cors_allowed_origins" {
  description = "The allowed origins for the CORS."
  default = null
}

variable "clerk_public_key" {
  description = "Clerk public key"
  type        = string
  default     = "clerk_public_key"
}

variable "clerk_issuer" {
  description = "Clerk issuer"
  type        = string
  default     = "clerk_issuer"
}

variable "clerk_audience" {
  description = "Clerk audience"
  type        = string
  default     = "clerk_audience"
}

variable "create_key_signature" {
  type = bool
  description = "Create a KMS key for signatures"
  default = false
}

variable "key_policy" {
  type = string
  description = "JSON encoded KMS Key policy (use jsonencode)"
  default = null
}

variable "kms_description" { 
  type = string
  description = "IROCO2 KMS Key Pair Description"
  default = "IROCO2 KMS Key pair (public and private keys) for signing and verifying signed objects"
}

variable "region" {
  type = string
  default = null
  description = "Region for KMS Key"
}

variable "tags" {
  type = map(string)
  default = null
  description = "KMS key tags"
}

variable "kms_key_id" {
  type = string
  description = "KMS Key ARN or (if in same account) alias or ID "
}

variable "enable_key_rotation" {
  type = string
  description = "enable KMS key rotation or not"
  default = true
}

variable "customer_master_key_spec" {
  type = string
  description = "Master Key specs"
  default = "RSA_4096"
}
