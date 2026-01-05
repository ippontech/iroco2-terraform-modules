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

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "${var.namespace}-${var.environment}"

  cidr = var.cidr

  azs                   = var.azs[data.aws_region.this.name]
  public_subnets        = var.public_subnets
  public_subnet_names   = [for az in var.azs[var.aws_region] : "${var.namespace}-${var.environment}-public-subnet-${az}"]
  private_subnets       = var.private_subnets
  private_subnet_names  = [for az in var.azs[var.aws_region] : "${var.namespace}-${var.environment}-private-subnet-${az}"]
  database_subnets      = var.database_subnets
  database_subnet_names = [for az in var.azs[var.aws_region] : "${var.namespace}-${var.environment}-database-subnet-${az}"]

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  enable_dns_hostnames = true
  enable_dns_support   = true

  map_public_ip_on_launch = true

  tags = {
    project = var.project_name
  }
}
