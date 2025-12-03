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
  lambda = {
    bucket_key    = "lambda/${var.namespace}/${var.project_name}"
    zip_path      = "${path.module}/${var.project_name}.zip"
    src_path      = "${path.module}/src/bootstrap"
    function_name = "lambda-${var.namespace}-${var.project_name}"
    handler       = var.project_name
    arch          = "arm64"
    runtime       = "provided.al2023"
    memory        = 128
    timeout       = 900
  }
}

data "archive_file" "authorizer" {
  type        = "zip"
  source_file = local.lambda.src_path
  output_path = local.lambda.zip_path
}

resource "aws_lambda_function" "lambda_function" {
  function_name = local.lambda.function_name
  role          = aws_iam_role.lambda_role_send.arn
  handler       = local.lambda.handler
  runtime       = local.lambda.runtime
  architectures = [local.lambda.arch]

  filename = local.lambda.zip_path

  source_code_hash = filebase64sha256(data.archive_file.authorizer.output_path)

  memory_size = local.lambda.memory

  environment {
    variables = {
      "IROCO2_KMS_IDENTITY_PUBLIC_KEY" = coalesce(var.kms_key_id, aws_kms_key.key)
    }
  }

  timeout = local.lambda.timeout
}
