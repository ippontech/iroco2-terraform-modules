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
    bucket_key    = "lambda/${var.project_name}/${var.namespace}/cur_processor"
    zip_path      = "${path.module}/cur_processor.zip"
    src_path      = "${path.module}/src"
    function_name = "lambda-cur-processor-${var.namespace}"
    handler       = "src.handler.send_parsed_cur_to_queue_handler.lambda_handler"
    runtime       = "python3.11"
    memory        = 4096
    timeout       = 900
    layers        = [aws_lambda_layer_version.lambda_layers.arn]
  }
}

# TODO: Retrieve the zip file from the GitHub release instead of zipping it here
data "archive_file" "cur_processor" {
  type = "zip"

  dynamic "source" {
    for_each = fileset(local.lambda.src_path, "**/*.py")
    content {
      content  = file("${local.lambda.src_path}/${source.value}")
      filename = "src/${source.value}"
    }
  }

  output_path = local.lambda.zip_path
}

resource "aws_lambda_function" "lambda_function" {

  function_name = local.lambda.function_name
  role          = aws_iam_role.lambda_role_send.arn
  handler       = local.lambda.handler
  runtime       = local.lambda.runtime

 filename = local.lambda.zip_path

  source_code_hash = filebase64sha256(data.archive_file.cur_processor.output_path)

  memory_size = local.lambda.memory

  environment {
    variables = {
      "QUEUE_URL" = aws_sqs_queue.analyzer_sqs_queue.url
      "REGION"    = data.aws_region.current.name
    }
  }

  layers = local.lambda.layers

  # depends_on = [aws_s3_object.cur_processor]

  timeout = local.lambda.timeout
}
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.cur_s3_bucket.arn
}
