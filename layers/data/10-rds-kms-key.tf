data "aws_caller_identity" "this" {}

resource "aws_kms_key" "rds" {
  description = "Key used to encrypt RDS ${var.namespace}"
  policy      = data.aws_iam_policy_document.kms_key_policy.json
}

resource "aws_kms_alias" "rds" {
  name          = "alias/kms-key-rds-irocalc"
  target_key_id = aws_kms_key.rds.id
}

data "aws_iam_policy_document" "kms_key_policy" {
  statement {
    sid = "Enable IAM User Permissions"
    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"]
      type        = "AWS"
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
}
