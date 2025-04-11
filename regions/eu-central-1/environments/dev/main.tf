module "aws-ecs-app" {
    source = "../../../../modules/aws-ecs-app"

    aws_region = var.aws_region
    service_name = var.service_name
    environment = var.environment
    cdn_secret_header = var.cdn_secret_header
    zone_id = var.zone_id
}