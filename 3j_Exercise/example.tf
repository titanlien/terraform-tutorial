terraform {
  backend "s3" {
    bucket = "tf-tutorial"
    key    = "3j/terraform.tfstate"
    region = "eu-west-1"
  }
}

locals {
  regions = {
    dev        = "eu-central-1"
    staging    = "eu-central-1"
    production = "eu-central-1"
  }

  instance_count = {
    dev        = "1"
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

