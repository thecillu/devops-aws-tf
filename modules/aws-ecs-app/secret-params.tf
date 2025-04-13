resource "aws_ssm_parameter" "app_secret_parameter" {
  name  = "/APP_SECRET_PARAMETER"
  type  = "SecureString"
  value = var.app_secret_parameter

    tags = {
        Name        = "${var.service_name}_app_secret_parameter"
        Environment = var.environment
    }
}