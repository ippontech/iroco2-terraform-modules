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

resource "aws_ecs_cluster" "main" {
  name = "${var.namespace}-${var.environment}-cluster"

  setting {
    # Enable container insights only for production environment (in order to reduce the cost induced by the service)
    name  = "containerInsights"
    value = var.container_insight_setting_value
  }

  tags = {
    project = var.project_name
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster_capacity" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = [var.capacity_provider]
}
