# TFLint configuration for IROCO2 Client Side Scanner Terraform module

config {
  # Enable all rules by default
  disabled_by_default = false

  # Plugin directory
  plugin_dir = "~/.tflint.d/plugins"

  # Call module inspection
  call_module_type = "all"
}

# AWS plugin configuration
plugin "aws" {
  enabled = true
  version = "0.29.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"

  # Deep checking requires AWS credentials
  deep_check = false
}

# Terraform plugin configuration
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# Rule configurations
rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_standard_module_structure" {
  enabled = true
}

# AWS specific rules
rule "aws_instance_invalid_type" {
  enabled = true
}

rule "aws_lambda_function_invalid_runtime" {
  enabled = true
}

rule "aws_s3_bucket_invalid_region" {
  enabled = true
}

rule "aws_iam_policy_invalid_policy" {
  enabled = true
}
