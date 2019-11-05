terraform {
  backend "s3" {
    bucket = "tf-tutorial"
    key    = "6a/terraform.tfstate"
    region = "eu-west-1"
  }
}

locals {
  regions = {
    dev        = "eu-central-1"
    staging    = "eu-central-1"
  }

  master_instance_count = {
    dev        = "1"
    staging    = "1"
  }

  worker_instance_count = {
    dev        = "0"
    staging    = "1"
  }
}

module "master" {
  source           = "./Master"
  region           = local.regions[terraform.workspace]
  number_instances = local.master_instance_count[terraform.workspace]
  vpc              = module.vpc
  sg-id            = aws_security_group.allow_ssh.id
}

module "worker" {
  source           = "./Worker"
  region           = local.regions[terraform.workspace]
  number_instances = local.worker_instance_count[terraform.workspace]
}

