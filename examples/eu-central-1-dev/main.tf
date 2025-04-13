module "aws-ecs-app" {
  source = "../../modules/aws-ecs-app"

  aws_region           = var.aws_region
  service_name         = var.service_name
  environment          = var.environment
  cdn_secret_header    = var.cdn_secret_header
  app_secret_parameter = var.app_secret_parameter
  zone_id              = var.zone_id
  app_image            = var.app_image
}

output "app_https_url" {
  description = "The App Custom Https url"
  value       = module.aws-ecs-app.app_https_url
}