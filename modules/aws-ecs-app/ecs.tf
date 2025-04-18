/* 
 * This file creates an ECS cluster, task definition, and service for a Fargate application.
*/
resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${local.service_env_name}-ecs-cluster"
  tags = {
    Name        = "${local.service_env_name}-ecs-cluster"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "ecs-log-group" {
  name = "/ecs/${local.service_env_name}"
  tags = {
    Name        = "${local.service_env_name}-ecs-log-group"
    Environment = var.environment
  }
}

resource "aws_ecs_task_definition" "app-task-definition" {
  family                   = "${local.service_env_name}-app-task"
  execution_role_arn       = aws_iam_role.ecs-task-execution-role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.app_fargate_cpu
  memory                   = var.app_fargate_memory
  container_definitions = templatefile("${path.module}/templates/app-template.json.tftpl", {
    service_name       = local.service_env_name
    app_image          = var.app_image
    app_port           = var.app_port
    app_fargate_cpu    = var.app_fargate_cpu
    app_fargate_memory = var.app_fargate_memory
    aws_region         = var.aws_region
    app_secret_parameter_arn = aws_ssm_parameter.app_secret_parameter.arn
  })

  tags = {
    Name        = "${local.service_env_name}-app-task"
    Environment = var.environment
  }
}

resource "aws_ecs_service" "app-ecs-service" {
  name            = "${local.service_env_name}-ecs-service"
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.app-task-definition.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"
  force_new_deployment = true
  network_configuration {
    security_groups  = [aws_security_group.ecs-security-group.id]
    subnets          = aws_subnet.private_subnet[*].id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.alb-target-group.arn
    container_name   = local.service_env_name
    container_port   = var.app_port
  }

  triggers = {
    redeployment = plantimestamp()
  }

  depends_on = [aws_alb_listener.alb-listener-http]

  tags = {
    Name        = "${local.service_env_name}-ecs-service"
    Environment = var.environment
  }
}