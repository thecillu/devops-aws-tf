data "aws_availability_zones" "availability_zones" {}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name        = "${local.service_env_name}-vpc"
    Environment = var.environment
  }
}