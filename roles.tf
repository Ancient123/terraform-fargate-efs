# Basic policy to allow tasks to create and push logging event
resource "aws_iam_policy" "nginx_taskexec_policy" {
  name = "nginx-taskexec"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}


# Attach the policy to a role that ecs can assume
resource "aws_iam_role" "nginx_taskexec_role" {
  name = "nginx-taskexec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = [aws_iam_policy.nginx_taskexec_policy.arn]
}

