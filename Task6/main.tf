provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Assignment-3"
      ManagedBy   = "Terraform"
      Environment = var.environment
      Task        = "Task6"
    }
  }
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  environment          = var.environment
}

module "security" {
  source = "./modules/security"

  vpc_id      = module.vpc.vpc_id
  environment = var.environment
}

module "compute" {
  source = "./modules/compute"

  ami_id             = var.custom_ami_id
  instance_type      = var.instance_type
  subnet_id          = module.vpc.public_subnet_ids[0]
  security_group_ids = [module.security.web_sg_id]
  key_name           = var.key_name
  environment        = var.environment
}
