terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

# =========================================================
# Network Module
# =========================================================

module "net" {
  source = "./modules/net"

  vpc_cidr      = var.vpc_cidr
  public_cidrs  = var.public_cidrs
  private_cidrs = var.private_cidrs
}

# =========================================================
# DB Module
# =========================================================

module "db" {
  source = "./modules/db"

  private_subnet_ids = module.net.private_subnet_ids

  db_sg_id = module.net.db_sg_id

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
}

# =========================================================
# EC2 Module
# =========================================================

module "ec2" {
  source = "./modules/ec2"

  private_subnet_ids = module.net.private_subnet_ids

  web_sg_id = module.net.web_sg_id

  db_endpoint = module.db.cluster_endpoint

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  key_name = var.key_name
}

# =========================================================
# ALB Module
# =========================================================

module "alb" {
  source = "./modules/alb"

  vpc_id = module.net.vpc_id

  public_subnet_ids = module.net.public_subnet_ids

  alb_sg_id = module.net.alb_sg_id
}

# =========================================================
# ASG Module
# =========================================================

module "asg" {
  source = "./modules/asg"

  private_subnet_ids = module.net.private_subnet_ids

  launch_template_id = module.ec2.launch_template_id

  target_group_arn = module.alb.target_group_arn
}

