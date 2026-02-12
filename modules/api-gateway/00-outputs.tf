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

output "base_url" {
  value       = aws_api_gateway_deployment.api_deployment_test.invoke_url
  description = "The base URL of the API Gateway deployment"
}

output "rest_api_id" {
  value       = aws_api_gateway_rest_api.Scanner_API.id
  description = "The ID of the REST API"
}

output "stage_name" {
  value       = aws_api_gateway_stage.api_stage_test.stage_name
  description = "The name of the API Gateway stage"
}
