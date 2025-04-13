output "app_https_url" {
  description = "The App Custom Https url"
  value       = "https://${var.service_name}.${var.environment}.${data.aws_route53_zone.provided-zone.name}"
}