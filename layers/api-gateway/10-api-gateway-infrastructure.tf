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

###################
### SCANNER API ###
###################
resource "aws_api_gateway_rest_api" "Scanner_API" {
  name        = "${var.namespace}-scanner-api-${var.environment}"
  description = "scanner-api"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

########################
### PAYLOAD CUR PART ###
########################
resource "aws_api_gateway_resource" "payload_cur_part_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.Scanner_API.id
  parent_id   = aws_api_gateway_rest_api.Scanner_API.root_resource_id
  path_part   = "payload-cur-part"
}

# Lambda Authorizer
resource "aws_api_gateway_authorizer" "lambda_authorizer" {
  name                             = "lambda-authorizer"
  rest_api_id                      = aws_api_gateway_rest_api.Scanner_API.id
  authorizer_uri                   = data.terraform_remote_state.lambda_authorizer.outputs.aws_lambda_invoke_arn
  authorizer_result_ttl_in_seconds = 300
  identity_source                  = "method.request.header.Authorization"
  type                             = "TOKEN"
}

# POST Method with Lambda Authorizer
resource "aws_api_gateway_method" "payload_cur_part_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.Scanner_API.id
  resource_id   = aws_api_gateway_resource.payload_cur_part_api_resource.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.lambda_authorizer.id
}

# Integration with SQS
data "aws_sqs_queue" "scanner_sqs_queue" {
  name = data.terraform_remote_state.cur_service.outputs.scanner_sqs_cur_name
}

resource "aws_api_gateway_integration" "payload_cur_part_sqs_integration" {
  rest_api_id             = aws_api_gateway_rest_api.Scanner_API.id
  resource_id             = aws_api_gateway_resource.payload_cur_part_api_resource.id
  http_method             = aws_api_gateway_method.payload_cur_part_post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  credentials             = aws_iam_role.api_gateway_sqs_role.arn
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:sqs:path/${data.aws_sqs_queue.scanner_sqs_queue.name}"
  request_templates = {
    "application/json" = "Action=SendMessage&MessageBody=$input.body"
  }

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }
}

# Lambda Permissions
resource "aws_lambda_permission" "authorizer_aws_permission" {
  statement_id  = "AllowAPIGatewayInvokeAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = data.terraform_remote_state.lambda_authorizer.outputs.aws_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.Scanner_API.id}/authorizers/${aws_api_gateway_authorizer.lambda_authorizer.id}"
}

# SQS permissions
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "api_gateway_permissions" {
  statement {
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = [data.aws_sqs_queue.scanner_sqs_queue.arn]
  }
}

resource "aws_iam_role" "api_gateway_sqs_role" {
  name               = "iam-for-api-gateway-sqs"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "api_gateway_sqs_policy" {
  name   = "sqs_permissions"
  role   = aws_iam_role.api_gateway_sqs_role.id
  policy = data.aws_iam_policy_document.api_gateway_permissions.json
}


# Method Response
resource "aws_api_gateway_method_response" "payload_cur_part_api_method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.Scanner_API.id
  resource_id = aws_api_gateway_resource.payload_cur_part_api_resource.id
  http_method = aws_api_gateway_method.payload_cur_part_post_method.http_method
  status_code = "200"
}

# Integration Response
resource "aws_api_gateway_integration_response" "payload_cur_part_api_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.Scanner_API.id
  resource_id = aws_api_gateway_resource.payload_cur_part_api_resource.id
  http_method = aws_api_gateway_method.payload_cur_part_post_method.http_method
  status_code = aws_api_gateway_method_response.payload_cur_part_api_method_response_200.status_code
}

##################
### DEPLOYMENT ###
##################
resource "aws_api_gateway_deployment" "api_deployment_test" {
  rest_api_id = aws_api_gateway_rest_api.Scanner_API.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.Scanner_API.body))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.payload_cur_part_sqs_integration
  ]
}

resource "aws_api_gateway_stage" "api_stage_test" {
  stage_name    = "test"
  rest_api_id   = aws_api_gateway_rest_api.Scanner_API.id
  deployment_id = aws_api_gateway_deployment.api_deployment_test.id

  lifecycle {
    ignore_changes = [deployment_id] # Prevents dependency cycle
  }
}
