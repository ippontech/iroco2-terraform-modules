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
  s3_layer_path_prefix = "lambda_layers/${var.namespace}"
  layers_path          = "${path.module}/../layers"
  layers               = fileset(local.layers_path, "*.zip")
}

resource "aws_s3_object" "layers" {
  for_each = local.layers

  bucket = aws_s3_bucket.lambda_s3_bucket.bucket
  key    = "${local.s3_layer_path_prefix}/${each.value}"
  source = "${local.layers_path}/${each.value}"

  etag = filemd5("${local.layers_path}/${each.value}")
}

resource "aws_lambda_layer_version" "lambda_layers" {

  for_each = local.layers

  layer_name          = split(".", each.value)[0]
  source_code_hash    = filebase64sha256("${local.layers_path}/${each.value}")
  compatible_runtimes = ["python3.11"]

  s3_bucket = aws_s3_bucket.lambda_s3_bucket.bucket
  s3_key    = "${local.s3_layer_path_prefix}/${each.value}"

  depends_on = [aws_s3_object.layers]
}
