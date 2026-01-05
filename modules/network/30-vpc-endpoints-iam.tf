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
    resources = ["arn:aws:ssm:*:*:*"]
  }

  statement {
    actions = [
      "ec2:DescribeVpcEndpoints",
      "ec2:DeleteVpcEndpoints",
      "ec2:CreateTags",
      "ec2:CreateVpcEndpoint"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role" "ssm" {
  count = var.create_vpc_endpoints ? 1 : 0

  name               = "${var.namespace}-${var.environment}-vpc-endpoints-scheduling"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ssm.json

}

resource "aws_iam_role_policy_attachment" "ssm_automation" {
  count = var.create_vpc_endpoints ? 1 : 0

  role       = aws_iam_role.ssm[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole"
}


resource "aws_iam_role_policy" "ssm" {
  count = var.create_vpc_endpoints ? 1 : 0

  name   = "${var.namespace}-${var.environment}-ssm-inline"
  policy = data.aws_iam_policy_document.ssm_inline.json
  role   = aws_iam_role.ssm[0].id
}
