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

resource "aws_cloudwatch_metric_alarm" "autoscale_alarm" {
  alarm_name          = "${var.namespace}-${var.project_name}-${var.environment}-failover-ALARM"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"

  treat_missing_data = "ignore"

  dimensions = {
    TargetGroup  = aws_lb_target_group.api.arn_suffix
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_description = "This alarm triggers if there is 1 or more unhealthy targets for more than 1 minute."
  alarm_actions = [
    aws_appautoscaling_policy.scale_out_policy.arn,
    aws_sns_topic.failover_email_topic.arn
  ]

  tags = {
    project = var.project_name
  }
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 1
  min_capacity       = 0
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  tags = {
    project = var.project_name
  }
}


resource "aws_appautoscaling_policy" "scale_out_policy" {
  name               = "scale-out"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ExactCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      scaling_adjustment          = 0
      metric_interval_lower_bound = 0
    }
  }
}
