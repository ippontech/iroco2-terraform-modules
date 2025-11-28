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
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "data" {
  backend = "s3"

  config = {
    region = "eu-west-3"
    bucket = var.tfstate_bucket
    key    = "infrastructure/eu-west-3/data/terraform.tfstate"
  }
}

data "aws_kms_public_key" "by_id" {
  key_id = data.terraform_remote_state.data.outputs.iroco_identity_provider_key_id
}
