resource "aws_kms_key" "iroco_identity_provider" {
  description              = "KMS key for identity provider in IroCO2"
  key_usage                = "SIGN_VERIFY"
  customer_master_key_spec = "RSA_4096"
}

resource "aws_kms_alias" "alias" {
  name          = "alias/${var.namespace}-identity-provider-key"
  target_key_id = aws_kms_key.iroco_identity_provider.id
}
