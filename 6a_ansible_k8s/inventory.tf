data "template_file" "inventory" {
  template = file("templates/inventory.tpl")

  depends_on = [
    module.master,
    module.worker,
  ]

  vars = {
    managers = join(
      "\n",
      module.master.*.public_ip,
    )
    nodes = join(
      "\n",
      module.worker.*.public_ip,
    )
  }
}

resource "null_resource" "cmd" {
  triggers = {
    template_rendered = data.template_file.inventory.rendered
  }

  provisioner "local-exec" {
    command = "echo '${data.template_file.inventory.rendered}' > ./ansible/inventory"
  }
}
