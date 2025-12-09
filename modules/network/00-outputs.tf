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

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnets
  description = "Private subnet IDs"
}

output "database_subnets_ids" {
  value       = module.vpc.database_subnets
  description = "Database subnet IDs"
}

output "security_group_ids" {
  value       = { for s in aws_security_group.this : s.name => s.id }
  description = "Security group IDs"
}

output "alb_listener_https_arn" {
  value       = aws_lb_listener.public_https.arn
  description = "ALB HTTPS listener ARN"
}
