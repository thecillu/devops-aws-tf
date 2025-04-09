variable "aws_region" {
  description = "The AWS region to deploy the VPC"
  type        = string
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
}

variable "public_subnets" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones to be used for the subnets"
  type        = list(string)
}