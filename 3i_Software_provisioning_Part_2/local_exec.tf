provider "aws" {
  region = "us-west-2"
}

resource "aws_spot_instance_request" "backend" {
  availability_zone      = "us-west-2a"
  ami                    = "ami-0b37e9efc396e4c38"
  instance_type          = "t3a.micro"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${var.sg-id}"]
  spot_price             = "0.01"
  spot_type              = "one-time"
  wait_for_fulfillment   = true
  subnet_id              = "subnet-09d9f37e03ac8d12c"

  # force Terraform to wait until a connection can be made, so that Ansible doesn't fail when trying to provision
  provisioner "remote-exec" {
    # The connection will use the local SSH agent for authentication
    inline = ["echo Successfully connected"]

    connection {
      user        = "ubuntu"
      type        = "ssh"
      private_key = "${file(var.pvt_key)}"
      host        = "${aws_spot_instance_request.backend.public_ip}"
    }
  }
}

#resource "null_resource" "ansible-pre-tasks" {
#  provisioner "local-exec" {
#    command = "ansible-playbook -e ssh-key=${var.pvt_key} -i '${aws_spot_instance_request.backend.public_ip},' ./ansible/pre-task.yml -v"
#  }
#
#  depends_on = ["aws_spot_instance_request.backend"]
#}

resource "null_resource" "ansible-main" {
  provisioner "local-exec" {
    command = "ssh-keyscan -H ${aws_spot_instance_request.backend.public_ip} >> ~/.ssh/known_hosts && ansible-playbook -e sshKey=${var.pvt_key} -i '${aws_spot_instance_request.backend.public_ip},' ./ansible/setup-backend.yaml -v"
  }

  depends_on = ["aws_spot_instance_request.backend"]
}
