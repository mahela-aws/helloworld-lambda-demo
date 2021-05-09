variable "sns_subscription_email" {
  description = "The email address for sns topic subscription"
  type        = string
}

variable "lambda_artifact_bucket" {
  description = "The s3 bucket for lambda artifact"
  type        = string
}
