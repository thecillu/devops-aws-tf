module "infra" {
    aws_region = var.aws_region
    source = "../../../../modules/infra"
    service_name = "my-service"
    environment = "dev"
    availability_zones = ["eu-central-1a", "eu-central-1b"]
    public_subnets = ["192.168.1.0/24", "192.168.2.0/24"]
    vpc_cidr = "192.168.0.0/16"
}