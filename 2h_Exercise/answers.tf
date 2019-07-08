provider "aws" {
  region     = "us-east-2"
}

provider "aws" {
  alias      = "us-west-2"
  region     = "us-west-2"
}

variable "us-east-zones" {
  default = ["us-east-2a", "us-east-2b"]
}

variable "us-west-zones" {
  default = ["us-west-2a", "us-west-2b"]
}

variable "instance_type" {
  default = ["t3a.small", "t3a.micro"]
}

resource "aws_spot_instance_request" "west_frontend" {
  count             = 2
  depends_on        = ["aws_spot_instance_request.west_backend"]
  provider          = "aws.us-west-2"
  ami               = "ami-01e24be29428c15b2"
  availability_zone = "${var.us-west-zones[count.index]}"
  instance_type     = "${var.instance_type[0]}"
  spot_price        = "0.03"
  spot_type         = "one-time"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_spot_instance_request" "frontend" {
  count             = 2
  depends_on        = ["aws_spot_instance_request.backend"]
  availability_zone = "${var.us-east-zones[count.index]}"
  ami               = "ami-02e680c4540db351e"
  instance_type     = "${var.instance_type[1]}"
  spot_price        = "0.03"
  spot_type         = "one-time"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_spot_instance_request" "west_backend" {
  provider          = "aws.us-west-2"
  ami               = "ami-01e24be29428c15b2"
  count             = 2
  availability_zone = "${var.us-west-zones[count.index]}"
  instance_type     = "${var.instance_type[0]}"
  spot_price        = "0.03"
  spot_type         = "one-time"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_spot_instance_request" "backend" {
  instance_type     = "${var.instance_type[1]}"
  count             = 2
  availability_zone = "${var.us-east-zones[count.index]}"
  ami               = "ami-02e680c4540db351e"
  spot_price        = "0.03"
  spot_type         = "one-time"

  lifecycle {
    prevent_destroy = true
  }
}

output "frontend_ip" {
  value = "${aws_spot_instance_request.frontend.*.public_ip}"
}

output "backend_ips" {
  value = "${aws_spot_instance_request.backend.*.public_ip}"
}
