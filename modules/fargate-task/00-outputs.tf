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

output "ecs_task_definition" {
  value       = aws_ecs_task_definition.api
  description = "ECS task definition"
}

output "ecs_service" {
  value       = aws_ecs_service.main
  description = "ECS service"
}

output "alb_target_group" {
  value       = aws_lb_target_group.api
  description = "ALB target group"
}

output "alb_listener_rule" {
  value       = aws_lb_listener_rule.api
  description = "ALB listener rule"
}
