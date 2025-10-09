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
resource "aws_sqs_queue" "analyzer_sqs_queue" {
  name                      = "sqs-${var.namespace}-${var.project_name}-analyzer"
  message_retention_seconds = 900

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.analyzer_deadletter.arn
    maxReceiveCount     = 4
  })
}

resource "aws_sqs_queue" "analyzer_deadletter" {
  name = "sqs-deadletter-${var.namespace}-${var.project_name}-analyzer"
}

resource "aws_sqs_queue_redrive_allow_policy" "terraform_analyzer_queue_redrive_allow_policy" {
  queue_url = aws_sqs_queue.analyzer_deadletter.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.analyzer_sqs_queue.arn]
  })
}

data "aws_iam_policy_document" "analyzer_sqs_policy_definition" {
  statement {
    sid    = "SQSAllowPolicy"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.id]
    }

    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage"
    ]
    resources = [aws_sqs_queue.analyzer_sqs_queue.arn]
  }
}

resource "aws_sqs_queue_policy" "analyzer_sqs_queue_policy_attachement" {
  queue_url = aws_sqs_queue.analyzer_sqs_queue.id
  policy    = data.aws_iam_policy_document.analyzer_sqs_policy_definition.json
}

resource "aws_ssm_parameter" "analyzer_sqs_queue" {
  name  = "/${upper(var.environment)}/${upper(var.project_name)}/ANALYZER_SQS_QUEUE_URL"
  type  = "String"
  value = aws_sqs_queue.analyzer_sqs_queue.id
}

resource "aws_sqs_queue" "scanner_sqs_queue" {
  name                      = "sqs-${var.namespace}-${var.project_name}-scanner"
  message_retention_seconds = 900

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.scanner_deadletter.arn
    maxReceiveCount     = 4
  })
}

resource "aws_sqs_queue" "scanner_deadletter" {
  name = "sqs-deadletter-${var.namespace}-${var.project_name}-scanner"
}

resource "aws_sqs_queue_redrive_allow_policy" "terraform_scanner_queue_redrive_allow_policy" {
  queue_url = aws_sqs_queue.scanner_deadletter.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.scanner_sqs_queue.arn]
  })
}

data "aws_iam_policy_document" "scanner_sqs_policy_definition" {
  statement {
    sid    = "SQSAllowPolicy"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.id]
    }

    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage"
    ]
    resources = [aws_sqs_queue.scanner_sqs_queue.arn]
  }
}

resource "aws_sqs_queue_policy" "scanner_sqs_queue_policy_attachement" {
  queue_url = aws_sqs_queue.scanner_sqs_queue.id
  policy    = data.aws_iam_policy_document.scanner_sqs_policy_definition.json
}

resource "aws_ssm_parameter" "scanner_sqs_queue" {
  name  = "/${upper(var.environment)}/${upper(var.project_name)}/SCANNER_SQS_QUEUE_URL"
  type  = "String"
  value = aws_sqs_queue.scanner_sqs_queue.id
}
