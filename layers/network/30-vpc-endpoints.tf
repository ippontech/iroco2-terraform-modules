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

variable "tag_autoshutdown" {
  type        = string
  description = "Describe how the ressources is managed: True if a ssm document is applied to start and stop the ressource"
  default     = "true"
}

resource "aws_ssm_document" "vpcendpoints_create" {
  name            = "CreateVpcEndpoints"
  document_format = "YAML"
  document_type   = "Automation"

  content = templatefile("${path.module}/template/CreateVpcEndpoints-function.yaml", {
    aws_iam_role_arn = aws_iam_role.ssm.arn
  })
}

resource "aws_ssm_document" "vpcendpoints_delete" {
  name            = "DeleteVpcEndpoints"
  document_format = "YAML"
  document_type   = "Automation"

  content = templatefile("${path.module}/template/DeleteVpcEndpoints-function.yaml", {
    aws_iam_role_arn = aws_iam_role.ssm.arn
  })
}

module "start_endpoint_scheduling_ssm" {
  source = "./modules/start_endpoint_scheduling_ssm"

  for_each = { for index, endpoint in local.vpc_endpoints_interface : endpoint.name_tag => endpoint }

  endpoint = each.value

  vpc_id          = module.vpc.vpc_id
  SecurityGroupId = try(each.value.security_group_id, null) != null ? each.value.security_group_id : null
  RouteTableIds   = module.vpc.private_route_table_ids
  SubnetIds       = [module.vpc.private_subnets[0]]

  tag_autoshutdown = var.tag_autoshutdown
  namespace        = var.namespace
  ssm_document     = aws_ssm_document.vpcendpoints_create.name
  working_days     = local.working_days
}

module "stop_endpoint_scheduling_ssm" {
  source = "./modules/stop_endpoint_scheduling_ssm"

  ssm_document     = aws_ssm_document.vpcendpoints_delete.name
  tag_autoshutdown = var.tag_autoshutdown
  working_days     = local.working_days
}
