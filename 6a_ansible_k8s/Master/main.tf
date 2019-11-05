provider "aws" {
  region = "${var.region}"
}

data "aws_availability_zones" "this" {}

resource "aws_spot_instance_request" "master" {
  count                  = "${var.number_instances}"
  availability_zone      = "${data.aws_availability_zones.this.names[count.index]}"
  ami                    = "ami-0957ba512eafd08d9"
  instance_type          = "t3a.micro"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${var.sg-id}"]
  spot_price             = "0.01"
  spot_type              = "one-time"
  wait_for_fulfillment   = true
  subnet_id              = "${var.vpc.public_subnets[0]}"

  # force Terraform to wait until a connection can be made, so that Ansible doesn't fail when trying to provision
  provisioner "remote-exec" {
    # The connection will use the local SSH agent for authentication
    inline = ["echo Successfully connected"]

    connection {
      user        = "centos"
      type        = "ssh"
      private_key = "${file(var.pvt_key)}"
      host        = "${aws_spot_instance_request.master[count.index].public_ip}"
    }
  }
}

resource "null_resource" "ansible-master" {
  count     = "${var.number_instances}"
  provisioner "local-exec" {
    command = "ssh-keyscan -H ${aws_spot_instance_request.master[count.index].public_ip} >> ~/.ssh/known_hosts && ansible-playbook -i '${aws_spot_instance_request.master[count.index].public_ip},' ./ansible/site.yaml -u centos --ask-vault-pass"
  }

  depends_on = ["aws_spot_instance_request.master"]
}
