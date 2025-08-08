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

# Get the latest encrypted amazon 2 AMI
data "aws_ami" "amazon_linux_3" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_ami_copy" "amazon_linux_3_encrypted" {
  name              = "bastion-${data.aws_ami.amazon_linux_3.name}-encrypted-temp"
  description       = "A copy of ${data.aws_ami.amazon_linux_3.description} but encrypted"
  source_ami_id     = data.aws_ami.amazon_linux_3.id
  source_ami_region = data.aws_region.current.name
  encrypted         = true
  tags = {
    ImageType = "encrypted-al3-linux"
  }
}
