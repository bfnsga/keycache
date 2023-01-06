#################################
## CodeBuild
#################################
resource "aws_iam_role" "codebuild-role" {
  name        = "CodeBuildBaseRole"
  description = "Allows CodeBuild to build Docker image and push to ECR Private Repository."

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "codebuild.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
}

resource "aws_iam_policy" "codebuild-policy" {
  name        = "CodeBuildBasePolicy"
  description = "Allows CodeBuild to build and deploy Lambda functions."

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Resource" : "*",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild-role-policy" {
  role       = aws_iam_role.codebuild-role.name
  policy_arn = aws_iam_policy.codebuild-policy.arn
}