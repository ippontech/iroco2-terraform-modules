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
  instance_name = "${var.namespace}-${var.environment}-bastion-al23"
  asg_tags = {
    "Name"        = "${var.namespace}-${var.environment}-bastion-al23"
    "Description" = "Bastion based on ${data.aws_ami.amazon_linux_3.name} but encrypted and using SSM capabilities"
  }
}

resource "aws_launch_template" "bastion_launch_template" {
  count = var.create_bastion ? 1 : 0

  name = local.instance_name
  iam_instance_profile {
    arn = module.instance_profile_role[0].iam_instance_profile_arn
  }
  image_id                             = data.aws_ami.amazon_linux_3.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = var.instance_type
  vpc_security_group_ids               = [var.bastion_security_group_id]

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.bastion_volume_size
      volume_type           = "gp2"
      iops                  = 0
      delete_on_termination = true
      encrypted             = true
    }
  }

  tags = {
    project = var.project_name
  }
}

resource "aws_autoscaling_group" "asg" {
  count = var.create_bastion ? 1 : 0

  name                      = "${local.instance_name}-asg"
  min_size                  = 1
  max_size                  = 1
  force_delete              = true
  vpc_zone_identifier       = var.private_subnet_ids
  health_check_grace_period = 300
  health_check_type         = "EC2"
  termination_policies      = ["OldestInstance"]
  launch_template {
    id      = aws_launch_template.bastion_launch_template[0].id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [max_size, min_size]
  }

  dynamic "tag" {
    for_each = local.asg_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

# scheduling
resource "aws_autoscaling_schedule" "schedule_work_hours_down" {
  count = var.create_bastion ? 1 : 0

  scheduled_action_name  = "schedule_work_hours_down"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  autoscaling_group_name = aws_autoscaling_group.asg[0].name
  recurrence             = var.down_recurrence
}

# scheduling
resource "aws_autoscaling_schedule" "schedule_work_hours_up" {
  count = var.create_bastion ? 1 : 0

  scheduled_action_name  = "schedule_work_hours_up"
  min_size               = 1
  max_size               = 1
  desired_capacity       = 1
  autoscaling_group_name = aws_autoscaling_group.asg[0].name
  recurrence             = var.up_recurrence
}
