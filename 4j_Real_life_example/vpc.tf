provider "aws" {
  region = "us-west-2"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "terraform"

  cidr = "10.10.0.0/16"

  azs             = ["us-west-2b", "us-west-2c"]
  public_subnets  = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnets = ["10.10.3.0/24", "10.10.4.0/24"]

  enable_nat_gateway = true

  tags = {
    Owner       = "user"
    Environment = "${terraform.workspace}"
    Name        = "teffaform vpc"
  }
}

