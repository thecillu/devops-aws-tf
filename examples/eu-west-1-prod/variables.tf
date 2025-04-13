variable "aws_region" {
  description = "The AWS region to deploy the resources in."
  type        = string
  default     = "eu-west-1"
}

variable "service_name" {
  description = "The name of the service"
  type        = string
  default     = "my-service"
}
variable "environment" {
  description = "The environment (e.g., dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "app_fargate_cpu" {
  description = "The amount of Fargate CPU to use"
  type        = string
  default     = "256"
}

variable "app_fargate_memory" {
  description = "The amount of Fargate memory to use"
  type        = string
  default     = "512"
}

variable "cdn_secret_header" {
  description = "Secret header for CDN"
  type        = string
  sensitive   = true
}

variable "zone_id" {
  description = "Route53 zone ID"
  type        = string
}
