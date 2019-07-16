terraform {
  backend "s3" {
    bucket = "tfm-titan"
    key    = "tutorial/terraform.tfstate"
    region = "us-east-1"
  }
}

locals {
  regions = {
    staging    = "us-west-2"
    production = "us-west-2"
  }

  instance_count = {
    staging    = "1"
    production = "1"
  }
}

module "backend" {
  source           = "./Backend"
  region           = local.regions[terraform.workspace]
  number_instances = local.instance_count[terraform.workspace]
}

module "frontend" {
  source           = "./Frontend"
  region           = local.regions[terraform.workspace]
  number_instances = local.instance_count[terraform.workspace]
}

