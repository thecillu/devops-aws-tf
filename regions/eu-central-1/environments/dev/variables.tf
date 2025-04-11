variable "aws_region" {
  description = "The AWS region to deploy the resources in."
  type        = string
  default     = "eu-central-1"
}

variable cdn_secret_header {
  description = "Secret header for CDN"
  type        = string
  sensitive = true
}
