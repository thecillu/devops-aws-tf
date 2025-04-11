/*
  Creates the IAM roles and policies required for ECS tasks and services.
  It also creates an S3 bucket for logging and sets up the necessary permissions for ALB and CloudFront to write logs to the bucket.
*/

data "aws_iam_policy_document" "iam-policy-document" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECS task execution role
resource "aws_iam_role" "ecs-task-execution-role" {
  name               = "${var.service_name}-TaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.iam-policy-document.json

  tags = {
    Name        = "${local.service_env_name}-TaskExecutionRole"
    Environment = var.environment
  }
}

# ECS task execution role policy attachment
resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment" {
  role       = aws_iam_role.ecs-task-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

/* Enable Access to Bucket Logs for ALB */
data "aws_elb_service_account" "elb_identity" {}

resource "aws_s3_bucket" "bucket_logs" {
  bucket = "${var.service_name}-${var.environment}-logs"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.bucket_logs.id
  policy = data.aws_iam_policy_document.s3_bucket_logs_write.json
}

data "aws_iam_policy_document" "s3_bucket_logs_write" {
  policy_id = "s3_bucket_logs_write"

  statement {
    actions = [
      "s3:PutObject",
      "s3:GetBucketAcl"
    ]
    effect = "Allow"

    resources = [
      "${aws_s3_bucket.bucket_logs.arn}",
      "${aws_s3_bucket.bucket_logs.arn}/*",
    ]

    principals {
      identifiers = ["${data.aws_elb_service_account.elb_identity.arn}"]
      type        = "AWS"
    }

    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }
}

/* 
 * Enable Access to Bucket Logs for CloudFront by documentation:
 * 'The bucket must have correct ACL attached with "FULL_CONTROL" permission for "awslogsdelivery" account 
 * (Canonical ID: "c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d0") for log transfer to work.'
*/

data "aws_canonical_user_id" "current" {}

resource "aws_s3_bucket_ownership_controls" "ownership_controls" {
  bucket = aws_s3_bucket.bucket_logs.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.bucket_logs.id
  access_control_policy {
    grant {
      grantee {
        id   = data.aws_canonical_user_id.current.id
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }
    owner {
      id = data.aws_canonical_user_id.current.id
    }
  }
  depends_on = [aws_s3_bucket_ownership_controls.ownership_controls]
}