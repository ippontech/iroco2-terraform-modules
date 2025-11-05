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
      name_tag          = "VPCendpoint_ECR_api",
      security_group_id = aws_security_group.this["vpce_ecr_api"].id
    },
    {
      service_name = "com.amazonaws.eu-west-3.s3",
      type         = "Gateway",
      name_tag     = "VPC_S3_endpoint"
    },
    {
      service_name      = "com.amazonaws.eu-west-3.ecr.dkr",
      type              = "Interface",
      name_tag          = "VPCendpoint_ECR_dkr",
      security_group_id = aws_security_group.this["vpce_ecr_dkr"].id
    },
    {
      service_name      = "com.amazonaws.eu-west-3.logs",
      type              = "Interface",
      name_tag          = "VPC_Cloudwatch_endpoint",
      security_group_id = aws_security_group.this["vpce_logs"].id
    },
    {
      service_name      = "com.amazonaws.eu-west-3.secretsmanager",
      type              = "Interface",
      name_tag          = "VPC_SecretManager_endpoint",
      security_group_id = aws_security_group.this["vpce_secrets_manager"].id
    },
    {
      service_name      = "com.amazonaws.eu-west-3.sqs",
      type              = "Interface",
      name_tag          = "VPC_SQS_endpoint",
      security_group_id = aws_security_group.this["vpce_sqs"].id
    },
    {
      service_name      = "com.amazonaws.eu-west-3.ssm",
      type              = "Interface",
      name_tag          = "VPC_SSM_endpoint",
      security_group_id = aws_security_group.this["vpce_ssm"].id
    },
    {
      service_name      = "com.amazonaws.eu-west-3.ssmmessages",
      type              = "Interface",
      name_tag          = "VPC_SSMmessages_endpoint",
      security_group_id = aws_security_group.this["vpce_ssm_messages"].id
    },
    {
      service_name      = "com.amazonaws.eu-west-3.ec2",
      type              = "Interface",
      name_tag          = "VPC_EC2_endpoint",
      security_group_id = aws_security_group.this["vpce_ec2"].id
    },
    {
      service_name      = "com.amazonaws.eu-west-3.kms",
      type              = "Interface",
      name_tag          = "VPC_KMS_endpoint",
      security_group_id = aws_security_group.this["vpce_kms"].id
    }
  ]

  working_days = ["MON", "TUE", "WED", "THU", "FRI"]
}

