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
  endpoint_ssm_parameter = {
    VpcId             = var.vpc_id
    SubnetIds         = var.endpoint.type == "Interface" ? var.SubnetIds : null
    ServiceName       = var.endpoint.service_name
    VpcEndpointType   = var.endpoint.type
    PrivateDnsEnabled = var.endpoint.type == "Interface" ? true : false
    SecurityGroupId   = var.endpoint.type == "Interface" ? [var.SecurityGroupId] : null
    RouteTableIds     = var.endpoint.type == "Gateway" ? var.RouteTableIds : null
    TagSpecifications = [
      {
        ResourceType = "vpc-endpoint"
        Tags = [
          {
            Key   = "Name"
            Value = var.endpoint.name_tag
          },
          {
            Key   = "namespace"
            Value = var.namespace
          },
          {
            Key   = "auto-shutdown"
            Value = var.tag_autoshutdown
          }
        ]
      }
    ]
  }
}
