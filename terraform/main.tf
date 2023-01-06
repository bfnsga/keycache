module "ecr" {
  source = "./modules/ecr"
}

module "codebuild" {
  source = "./modules/codebuild"

  repository_name = module.ecr.repository_name
  aws_account_id = var.aws_account_id
  aws_region = var.aws_region
}