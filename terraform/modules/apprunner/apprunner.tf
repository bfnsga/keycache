#########################
## AppRunner
#########################

## IAM - Access Role
#########################
resource "aws_iam_role" "apprunner-access_role" {
  name = "AppRunnerAccessRole"

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

resource "aws_iam_policy" "apprunner-access_policy" {
  name        = "AppRunnerAccessPolicy"
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

resource "aws_iam_role_policy_attachment" "apprunner-access_role_policy" {
  role       = aws_iam_role.apprunner-access_role.name
  policy_arn = aws_iam_policy.apprunner-access_policy.arn
}

## IAM - Instance Role
#########################
resource "aws_iam_role" "apprunner-instance_role" {
  name = "AppRunnerInstanceRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "tasks.apprunner.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "apprunner-instance_policy" {
  name        = "AppRunnerInstancePolicy"
  description = "Allows AppRunner access AWS resources."

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Resource" : "*",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "apprunner-instance_role_policy" {
  role       = aws_iam_role.apprunner-instance_role.name
  policy_arn = aws_iam_policy.apprunner-instance_policy.arn
}

## Cloudwatch Log Group
#########################
resource "aws_cloudwatch_log_group" "apprunner" {
  name = "/apprunner/production-service"
  retention_in_days = 7
}

## AppRunner Service
#########################
resource "aws_apprunner_service" "example" {
  service_name = "example"
  log_group_name = aws_cloudwatch_log_group.apprunner.name

  source_configuration {
    authentication_configuration {
      connection_arn = "arn:aws:apprunner:us-east-2:762260721599:connection/AppRunner/fd27de26f8624e0a8826ad18d7656cad"
    }
    code_repository {
      code_configuration {
        configuration_source = "REPOSITORY"
      }
      repository_url = "https://github.com/bfnsga/keycache"
      source_code_version {
        type  = "BRANCH"
        value = "main"
      }
    }
    auto_deployments_enabled = false
  }

  instance_configuration {
    instance_role_arn = aws_iam_role.apprunner-instance_role.arn
  }
}