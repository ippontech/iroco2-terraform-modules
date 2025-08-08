# TODO: remove this variable and the associated feature
variable "email_addresses" {
  default = []
  type        = list(string)
  description = "List of email addresses to be used by SES to send emails to Iroco's responsibles"
}
