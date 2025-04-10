# ECS task execution role data
data "aws_iam_policy_document" "iam-policy-document" {
  version = "2012-10-17"
  statement {
    sid = ""
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECS task execution role
resource "aws_iam_role" "ecs-task-execution-role" {
  name = "${var.service_name}-TaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.iam-policy-document.json

  tags = {
    Name = "${var.service_name}-TaskExecutionRole"
    Environment = var.environment
  }
}

# ECS task execution role policy attachment
resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment" {
  role = aws_iam_role.ecs-task-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}