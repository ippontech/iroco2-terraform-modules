module "instance_profile_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 3.0"

  role_name               = "${var.namespace}-${var.environment}-bastion-al23-instance-role"
  create_role             = true
  create_instance_profile = true
  role_requires_mfa       = false

  trusted_role_services = ["ec2.amazonaws.com"]
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/EC2InstanceConnect"
  ]
}
