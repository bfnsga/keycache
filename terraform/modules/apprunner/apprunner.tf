#########################
## AppRunner
#########################

## IAM ROLE
#########################
resource "aws_iam_role" "apprunner_role" {
  name = "AppRunnerBaseRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "build.apprunner.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "apprunner_policy" {
  name        = "AppRunnerBasePolicy"
  description = "Allows AppRunner access to ECR Private Repository."

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Resource" : "*",
        "Action" : [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:GetAuthorizationToken"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "apprunner_role_policy" {
  role       = aws_iam_role.apprunner_role.name
  policy_arn = aws_iam_policy.apprunner_policy.arn
}

## AppRunner Service
#########################
resource "aws_apprunner_service" "example" {
  service_name = "example"

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_role.arn
    }
    image_repository {
      image_configuration {
        port = "8000"
      }
      image_identifier      = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.repository_name}:LATEST"
      image_repository_type = "ECR"
    }
    auto_deployments_enabled = false
  }
}