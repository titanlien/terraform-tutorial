provider "aws" {
  region = "${var.region}"
}

resource "aws_spot_instance_request" "frontend" {
  count                  = "${var.number_instances}"
  availability_zone      = "${data.aws_availability_zones.this.names[count.index]}"
  ami                    = "ami-0b37e9efc396e4c38"
  instance_type          = "t3a.micro"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${var.sg-id}"]
  spot_price             = "0.01"
  spot_type              = "one-time"
  wait_for_fulfillment   = true
  subnet_id              = "subnet-09d9f37e03ac8d12c"

  lifecycle {
    create_before_destroy = true
  }

  connection {
    user        = "ubuntu"
    type        = "ssh"
    private_key = "${file(var.pvt_key)}"
    host        = "${aws_spot_instance_request.frontend.public_ip}"
  }

  provisioner "file" {
    source      = "./frontend"
    destination = "~/"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ~/frontend/run_frontend.sh",
      "cd ~/frontend",
      "sudo ~/frontend/run_frontend.sh",
    ]
  }
}
