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
  name               = "${var.namespace}-vpc-endpoints-scheduling"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ssm.json

  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole"]
}

resource "aws_iam_role_policy" "ssm" {
  name   = "ssm-inline"
  policy = data.aws_iam_policy_document.ssm_inline.json
  role   = aws_iam_role.ssm.id
}
