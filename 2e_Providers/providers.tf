provider "aws" {
  region     = "us-east-1"
}

provider "aws" {
  alias      = "us-west-1"
  region     = "us-west-1"
}

resource "aws_instance" "us_west_example" {
  provider      = "aws.us-west-1"
  ami           = "ami-07585467"
  instance_type = "t2.micro"
}

resource "aws_instance" "us_east_example" {
  ami           = "ami-66506c1c"
  instance_type = "t2.micro"
}
