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
  layers_path          = "${path.module}/src"
  layers               = fileset(local.layers_path, "*.zip")
  output_path          = "${path.module}/layers.zip"
}

data "archive_file" "layers" {
  type        = "zip"
  source_dir  = local.layers_path
  output_path = local.output_path
}

resource "aws_lambda_layer_version" "lambda_layers" {

  layer_name          = "iroco2-cur-analyzer-layers"
  compatible_runtimes = ["python3.11"]

  filename = local.output_path
  depends_on = [ data.archive_file.layers]
}
