provider "aws" {
  region = "${local.regions[terraform.workspace]}"
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["217.86.133.43/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "k8s"

  cidr = "10.10.0.0/16"

  azs             = ["${local.regions[terraform.workspace]}a"]
  public_subnets  = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnets = ["10.10.11.0/24", "10.10.12.0/24"]

  enable_nat_gateway = true

  tags = {
    Project     = "k8s"
    Environment = "${terraform.workspace}"
    Name        = "teffaform vpc"
  }
}

