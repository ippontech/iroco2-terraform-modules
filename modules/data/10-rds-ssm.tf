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

locals {
  working_days = ["MON", "TUE", "WED", "THU", "FRI"]
}

data "aws_iam_policy_document" "ssm" {

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com", "ssm.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}

data "aws_iam_policy_document" "ssm_inline" {
  statement {
    actions   = ["iam:PassRole"]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "rds:DescribeDBInstances",
      "rds:StartDBInstance",
      "rds:StopDBInstance"
    ]
    effect    = "Allow"
    resources = [module.rds.db_instance_arn]
  }
}

resource "aws_iam_role" "ssm" {
  name               = "${var.namespace}-${var.environment}-rds-scheduling"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ssm.json

  tags = {
    project = var.project_name
  }
}

resource "aws_iam_policy" "ssm_inline" {
  name   = "${var.namespace}-${var.environment}-ssm-inline"
  policy = data.aws_iam_policy_document.ssm_inline.json

  tags = {
    project = var.project_name
  }
}

resource "aws_iam_role_policy_attachment" "ssm_inline" {
  role       = aws_iam_role.ssm.name
  policy_arn = aws_iam_policy.ssm_inline.arn
}

resource "aws_iam_role_policy_attachment" "ssm_automation" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole"
}

resource "aws_ssm_association" "start_rds" {
  for_each = toset(local.working_days)

  apply_only_at_cron_interval = true

  name = "AWS-StartRdsInstance"

  automation_target_parameter_name = "InstanceId"

  association_name = "${var.namespace}-${var.environment}-StartRds-${each.value}"

  schedule_expression = "cron(0 6 ? * ${each.value} *)" #GMT -> 8 AM in Paris

  parameters = {
    InstanceId           = local.rds_db_identifier
    AutomationAssumeRole = aws_iam_role.ssm.arn
  }

  targets {
    key    = "ParameterValues"
    values = [local.rds_db_identifier]
  }

  tags = {
    project = var.project_name
  }
}

resource "aws_ssm_association" "stop_rds" {
  for_each = toset(local.working_days)

  name = "AWS-StopRdsInstance"

  apply_only_at_cron_interval = true

  automation_target_parameter_name = "InstanceId"

  association_name = "${var.namespace}-${var.environment}-StopRds-${each.value}"

  schedule_expression = "cron(30 18 ? * ${each.value} *)" #GMT -> 8:30 PM in Paris

  parameters = {
    InstanceId           = local.rds_db_identifier
    AutomationAssumeRole = aws_iam_role.ssm.arn
  }

  targets {
    key    = "ParameterValues"
    values = [local.rds_db_identifier]
  }

  tags = {
    project = var.project_name
  }
}
