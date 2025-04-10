resource "aws_cloudwatch_log_group" "yada" {
  name = "/ecs/${var.service_name}"

  tags = {
    Name = "${var.service_name}-log-group"
  }
}