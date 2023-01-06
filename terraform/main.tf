module "iam" {
  source = "./modules/iam"
}

module "ecr" {
  source = "./modules/ecr"
}