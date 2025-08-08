variable "parameters_list" {
  type        = list(string)
  description = "List of parameters (name only) used in Iroco"
  default = [
    "clerk_audience",
    "clerk_issuer",
    "clerk_public_key",
    "clerk_publishable_key"
  ]
}
