#########################
## CodeBuild - Production Project
#########################

## IAM ROLE
#########################
resource "aws_iam_role" "codebuild_role" {
  name = "CodeBuildBaseRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "codebuild_policy" {
  name        = "CodeBuildBasePolicy"
  description = "Allows CodeBuild access to ECR Private Repository."

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Resource" : "*",
        "Action" : [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_role_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}

## CODEBUILD PROJECT
#########################
data "local_file" "buildspec" {
  filename = "${path.module}/buildspec/ecr-image.yml"
}

resource "aws_codebuild_project" "image" {
  name          = "image-v1"
  build_timeout = "15"
  service_role  = aws_iam_role.codebuild_role.arn
  concurrent_build_limit = "1"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = true

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.aws_account_id
    }

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = var.repository_name
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "LATEST"
    }

  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/codebuild/production-image"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/bfnsga/keycache.git"
    git_clone_depth = 1
    buildspec       = data.local_file.buildspec.content

  }
}

resource "aws_codebuild_webhook" "webhook" {
  project_name = aws_codebuild_project.image.name
  build_type   = "BUILD"
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }

    filter {
      type    = "HEAD_REF"
      pattern = "main"
    }
  }
}

## CLOUDWATCH LOG GROUP
#########################
resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/codebuild/production-image"
  retention_in_days = 14
}