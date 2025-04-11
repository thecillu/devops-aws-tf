variable "aws_region" {
  description = "The AWS region to deploy the VPC"
  type        = string
  default     = "eu-central-1"
}

variable "service_name" {
  description = "The name of the service"
  type        = string
}
variable "environment" {
  description = "The environment (e.g., dev, staging, prod)"
  type        = string
}

variable vpc_cidr {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "192.168.0.0/16"
}

variable app_port {
  description = "The CIDR block for the VPC"
  type        = number
  default     =  3000
}

variable app_image {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "duplocloud/nodejs-hello"
}


variable app_fargate_cpu {
  description = "The amount of Fargate CPU to use"
  type        = string
  default     = "256"
}

variable app_fargate_memory {
  description = "The amount of Fargate memory to use"
  type        = string
  default     = "512"
}
variable app_count {
  description = "The number of Fargate tasks to run"
  type        = number
  default     = 1
}

variable alb_logging_enabled {
  description = "Enable ALB logging"
  type        = bool
  default     = false
}

variable cdn_logging_enabled {
  description = "Enable CDN logging"
  type        = bool
  default     = false
}

variable cdn_secret_header {
  description = "Secret header for CDN"
  type        = string
  sensitive = true
}

