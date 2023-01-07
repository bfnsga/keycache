module "apprunner" {
  source = "./modules/apprunner"

  aws_account_id = var.aws_account_id
  aws_region = var.aws_region
}