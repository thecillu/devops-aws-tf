module "infra" {
    source = "../../../../modules/aws-ecs-app"
    aws_region = var.aws_region
    service_name = "my-service"
    environment = "dev"
    cdn_secret_header = var.cdn_secret_header
}