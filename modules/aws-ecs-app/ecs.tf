resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.service_name}-ecs-cluster"
    tags = {
        Name        = "${var.service_name}-ecs-cluster"
        Environment = var.environment
    }
}

resource "aws_ecs_task_definition" "app-task-definition" {
  family                   = "${var.service_name}-app-task"
  execution_role_arn       = aws_iam_role.ecs-task-execution-role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.app_fargate_cpu
  memory                   = var.app_fargate_memory
  container_definitions    = templatefile("${path.module}/templates/app-template.json.tftpl", {
                                service_name   = var.service_name
                                app_image      = var.app_image
                                app_port       = var.app_port
                                app_fargate_cpu    = var.app_fargate_cpu
                                app_fargate_memory = var.app_fargate_memory
                                aws_region     = var.aws_region
                            })

    tags = {
        Name        = "${var.service_name}-app-task"
        Environment = var.environment
    }
}

resource "aws_ecs_service" "app-ecs-service" {
  name            = "${var.service_name}-ecs-service"
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.app-task-definition.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs-security-group.id]
    subnets          = aws_subnet.private_subnet.*.id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.alb-target-group.arn
    container_name   = "${var.service_name}"
    container_port   = var.app_port
  }

  depends_on = [aws_alb_listener.alb-listener-http]

  tags = {
        Name        = "${var.service_name}-ecs-service"
        Environment = var.environment
    }
}