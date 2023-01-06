module "ecr" {
  source = "./modules/ecr"
}

module "codebuild" {
  source = "./modules/codebuild"

  repository_name = module.ecr.repository_name
  aws_account_id = var.aws_account_id
  aws_region = var.aws_region
  github_credentials = var.github_credentials
}

module "apprunner" {
  source = "./modules/apprunner"

  repository_name = module.ecr.repository_name
  aws_account_id = var.aws_account_id
  aws_region = var.aws_region
}