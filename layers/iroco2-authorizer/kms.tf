resource "aws_kms_key" "key" {
    count       = (var.create_key_signature ? 1 : 0)
    key_usage   = "SIGN_VERIFY"
    description = var.kms_description
    enable_key_rotation = var.enable_key_rotation
    customer_master_key_spec = var.customer_master_key_spec
    tags = var.tags
}