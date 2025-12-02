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
  vpc_endpoints_interface = [
    {
      service_name      = "com.amazonaws.eu-west-3.ecr.api",
      type              = "Interface",
      name_tag          = "${var.namespace}-${var.environment}-vpce-ecr-api",
      security_group_id = aws_security_group.this["vpce_ecr_api"].id
    },
    {
      service_name = "com.amazonaws.eu-west-3.s3",
      type         = "Gateway",
      name_tag     = "${var.namespace}-${var.environment}-vpce-s3-gateway"
    },
    {
      service_name      = "com.amazonaws.eu-west-3.ecr.dkr",
      type              = "Interface",
      name_tag          = "${var.namespace}-${var.environment}-vpce-ecr-dkr",
      security_group_id = aws_security_group.this["vpce_ecr_dkr"].id
    },
    {
      service_name      = "com.amazonaws.eu-west-3.logs",
      type              = "Interface",
      name_tag          = "${var.namespace}-${var.environment}-vpce-cloudwatch",
      security_group_id = aws_security_group.this["vpce_logs"].id
    },
    {
      service_name      = "com.amazonaws.eu-west-3.secretsmanager",
      type              = "Interface",
      name_tag          = "${var.namespace}-${var.environment}-vpce-secrets-manager",
      security_group_id = aws_security_group.this["vpce_secrets_manager"].id
    },
    {
      service_name      = "com.amazonaws.eu-west-3.sqs",
      type              = "Interface",
      name_tag          = "${var.namespace}-${var.environment}-vpce-sqs",
      security_group_id = aws_security_group.this["vpce_sqs"].id
    },
    {
      service_name      = "com.amazonaws.eu-west-3.ssm",
      type              = "Interface",
      name_tag          = "${var.namespace}-${var.environment}-vpce-ssm",
      security_group_id = aws_security_group.this["vpce_ssm"].id
    },
    {
      service_name      = "com.amazonaws.eu-west-3.ssmmessages",
      type              = "Interface",
      name_tag          = "${var.namespace}-${var.environment}-vpce-ssm-messages",
      security_group_id = aws_security_group.this["vpce_ssm_messages"].id
    },
    {
      service_name      = "com.amazonaws.eu-west-3.ec2",
      type              = "Interface",
      name_tag          = "${var.namespace}-${var.environment}-vpce-ec2",
      security_group_id = aws_security_group.this["vpce_ec2"].id
    },
    {
      service_name      = "com.amazonaws.eu-west-3.kms",
      type              = "Interface",
      name_tag          = "${var.namespace}-${var.environment}-vpce-kms",
      security_group_id = aws_security_group.this["vpce_kms"].id
    }
  ]

  working_days = ["MON", "TUE", "WED", "THU", "FRI"]
}
