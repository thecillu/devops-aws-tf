terraform {

    required_version = ">= 1.9.5"

    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
        }
    }

  backend "s3" {
    bucket = "" 
    key    = ""
    region = ""
    profile= ""
  }
}

provider aws {
  region = var.aws_region
}