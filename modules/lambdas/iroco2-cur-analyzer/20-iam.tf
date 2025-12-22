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
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "lambda_permissions" {
  statement {
    effect = "Allow"

    actions = [
      "sqs:SendMessage"
    ]

    resources = [aws_sqs_queue.analyzer_sqs_queue.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.cur_s3_bucket.arn}/*",
      aws_s3_bucket.cur_s3_bucket.arn
    ]
  }
}

resource "aws_iam_role" "lambda_role_send" {
  name               = "${var.namespace}-${var.environment}-${var.project_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    project = var.project_name
  }
}

resource "aws_iam_role_policy" "sqs_permissions" {
  name   = "${var.namespace}-${var.environment}-${var.project_name}-lambda-sqs-policy"
  role   = aws_iam_role.lambda_role_send.id
  policy = data.aws_iam_policy_document.lambda_permissions.json
}

data "aws_iam_policy_document" "log_cloud" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}
