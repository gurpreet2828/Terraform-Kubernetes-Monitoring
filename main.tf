#-----main.tf-----
#===================
terraform {
  required_providers {
    aws = {
      version = "~> 3.44.0"
    }
  }

  required_version = ">= 0.15.5"
}

provider "aws" {
  region = var.region
}

#Deploy Networking Resources
#============================
module "vpc" {
  source = "./modules/vpc"
}

#Deploy Compute Resources
#============================
module "compute" {
  source            = "./modules/compute"
  public_subnet_one = module.vpc.public_subnets_one
  public_subnet_two = module.vpc.public_subnets_two
  security_group    = module.vpc.public_sg
  subnet_ip_one     = module.vpc.subnet_ips_one
  subnet_ip_two     = module.vpc.subnet_ips_two
}
