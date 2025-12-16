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

# Task definition
resource "aws_ecs_task_definition" "api" {
  family                   = "${var.namespace}-${var.environment}-${var.project_name}"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.service.arn
  task_role_arn            = aws_iam_role.task.arn
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  container_definitions = jsonencode([
    {
      name        = var.project_name
      image       = var.container_image
      networkMode = "awsvpc"

      essential   = true
      environment = local.task_environment
      secrets     = concat(local.task_secrets_arn, local.task_secrets_arn_with_key)
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app_logs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }

    }
  ])

  tags = {
    project = var.project_name
  }
}

resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/ecs/service/${var.namespace}-${var.environment}-${var.project_name}/app-logs"
  retention_in_days = 5

  tags = {
    project = var.project_name
  }
}

# Service
resource "aws_ecs_service" "main" {
  name = "${var.namespace}-${var.environment}-${var.project_name}"

  cluster                = var.cluster_id
  launch_type            = "FARGATE"
  platform_version       = "1.4.0"
  task_definition        = aws_ecs_task_definition.api.arn
  desired_count          = var.container_desired_count
  enable_execute_command = true

  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = var.project_name
    container_port   = var.container_port
  }

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.service.id]
  }

  depends_on = [
    aws_iam_policy.service,
    aws_cloudwatch_log_group.app_logs
  ]

  tags = {
    project = var.project_name
  }
}

resource "aws_security_group" "service" {
  name        = "${var.namespace}-${var.environment}-${var.project_name}-service"
  description = "Allow HTTP inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port = var.container_port
    to_port   = var.container_port
    protocol  = "tcp"
    security_groups = [
      var.alb_security_group_id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    project = var.project_name
  }
}

# Scheduling
resource "aws_scheduler_schedule" "turn_off_in_the_evening" {
  name = "${aws_ecs_service.main.name}-turn-off-in-the-evening"

  schedule_expression          = "cron(0 20 ? * MON-FRI *)"
  schedule_expression_timezone = "Europe/Paris"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ecs:updateService"
    role_arn = aws_iam_role.scheduler.arn

    retry_policy {
      maximum_retry_attempts = 1
    }

    input = jsonencode({
      Cluster      = var.cluster_name
      Service      = aws_ecs_service.main.name
      DesiredCount = 0
    })
  }

  flexible_time_window {
    mode = "OFF"
  }
}

resource "aws_scheduler_schedule" "turn_on_in_the_morning" {
  name = "${aws_ecs_service.main.name}-turn-on-in-the-morning"

  schedule_expression          = "cron(30 8 ? * MON-FRI *)"
  schedule_expression_timezone = "Europe/Paris"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ecs:updateService"
    role_arn = aws_iam_role.scheduler.arn

    retry_policy {
      maximum_retry_attempts = 1
    }

    input = jsonencode({
      Cluster      = var.cluster_name
      Service      = aws_ecs_service.main.name
      DesiredCount = var.container_desired_count
    })
  }

  flexible_time_window {
    mode = "OFF"
  }
}

resource "aws_iam_role" "scheduler" {
  name               = "${aws_ecs_service.main.name}-office-hours-scaling"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    project = var.project_name
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "allow_update_service" {
  statement {
    actions = ["ecs:UpdateService"]

    resources = [aws_ecs_service.main.id]
  }
}

resource "aws_iam_role_policy" "allow_update_service" {
  role   = aws_iam_role.scheduler.name
  policy = data.aws_iam_policy_document.allow_update_service.json
}
