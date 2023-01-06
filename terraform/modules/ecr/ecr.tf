#################################
## ECR Private Repository
#################################
resource "aws_ecr_repository" "production_repository" {
  name                 = "production_repository"
  image_tag_mutability = "MUTABLE"
  force_destroy = true
}

resource "aws_ecr_lifecycle_policy" "policy" {
  repository = aws_ecr_repository.production_repository.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 5 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 5
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}