provider "aws" {
  region = var.region
}

locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Purpose     = "github-actions-deploy"
  }
}




module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  cloudflare_ipv4      = var.cloudflare_ipv4
  region               = var.region
}
module "cms_images" {
  source      = "./modules/s3"
  bucket_name = "tzone-images"
  region      = var.region
}


module "tfstate" {
  source      = "./modules/s3-tfstate"
  bucket_name = "tzone-tfstate" # Globally unique
  region      = var.region
}

module "ec2" {
  source                = "./modules/ec2"
  vpc_id                = module.vpc.vpc_id
  public_subnets        = module.vpc.public_subnets
  private_subnets       = module.vpc.private_subnets
  availability_zones    = var.availability_zones
  ami_map               = var.ami_map
  instance_type         = var.instance_type
  cloudflare_ipv4       = var.cloudflare_ipv4
  rds_security_group_id = module.rds.db_security_group_id
}

module "rds" {
  source = "./modules/rds"
  name   = "tz-cmsdb"

  snapshot_identifier     = "restored-snapshot" # db_name/username/password IGNORED during restore
  db_password             = "ChangeMe123!"      # Placeholder, not used during restore
  vpc_id                  = module.vpc.vpc_id
  vpc_cidr                = module.vpc.vpc_cidr
  private_subnets         = module.vpc.private_subnets
  allowed_security_groups = [module.ec2.Ec2InstanceConnect_security_group_id]
}


module "deploy_bucket" {
  source = "./modules/deploy_bucket"

  bucket_name    = var.bucket_name
  environment    = var.environment
  retention_days = var.artifact_retention_days
  tags           = local.common_tags
}

module "deploy_iam" {
  source = "./modules/deploy_iam"

  environment   = var.environment
  bucket_arn    = module.deploy_bucket.bucket_arn
  github_org    = var.github_org
  github_repo   = var.github_repo
  github_branch = var.github_branch
  asg_name      = var.asg_name
  tags          = local.common_tags
}
