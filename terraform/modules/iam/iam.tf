#################################
## CodeBuild
#################################
resource "aws_iam_role" "codebuild-role" {
  name        = "CodeBuildBaseRole"
  description = "Allows CodeBuild to build and deploy Lambda functions."

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
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation",
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages",
          "lambda:*",
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild-role-policy" {
  role       = aws_iam_role.codebuild-role.name
  policy_arn = aws_iam_policy.codebuild-policy.arn
}