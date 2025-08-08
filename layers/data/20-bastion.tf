locals {
  instance_name = "${var.namespace}-${var.environment}-bastion-al23"
  asg_tags = {
    "Name"        = "${var.namespace}-bastion-al23"
    "Description" = "Bastion based on ${data.aws_ami.amazon_linux_3.name} but encrypted and using SSM capabilities"
  }
}

resource "aws_launch_template" "bastion_launch_template" {
  name = local.instance_name
  iam_instance_profile {
    arn = module.instance_profile_role.this_iam_instance_profile_arn
  }
  image_id                             = aws_ami_copy.amazon_linux_3_encrypted.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = var.instance_type
  vpc_security_group_ids               = [data.terraform_remote_state.network.outputs.security_group_ids["bastion"]]

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
}


resource "aws_autoscaling_group" "asg" {
  name                      = "${local.instance_name}-asg"
  min_size                  = 1
  max_size                  = 1
  force_delete              = false
  vpc_zone_identifier       = data.terraform_remote_state.network.outputs.private_subnet_ids
  health_check_grace_period = 300
  health_check_type         = "EC2"
  termination_policies      = ["OldestInstance"]
  launch_template {
    id      = aws_launch_template.bastion_launch_template.id
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
  scheduled_action_name  = "schedule_work_hours_down"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  autoscaling_group_name = aws_autoscaling_group.asg.name
  recurrence             = var.down_recurrence
}
