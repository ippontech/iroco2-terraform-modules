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

resource "aws_ssm_association" "delete_vpc_endpoints" {

  for_each = toset(var.working_days)

  apply_only_at_cron_interval = true

  name = var.ssm_document

  association_name = "DeleteVpcEndpoint-${each.value}"

  schedule_expression = "cron(15 18 ? * ${each.value} *)" #GMT -> 8:15 PM in Paris

  parameters = {
    tagname     = var.tag_autoshutdown
    environment = var.environment
    namespace   = var.namespace
  }

  automation_target_parameter_name = "tagname"

  targets {
    key    = "ParameterValues"
    values = [var.tag_autoshutdown]
  }
}
