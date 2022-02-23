resource "oci_core_instance" "free_instance" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = var.display_name
  shape               = var.instance_shape

  source_details {
    source_type = "image"
    source_id   = var.image_id
  }
  create_vnic_details {
    assign_public_ip = true
    subnet_id        = var.subnet_id
    private_ip       = var.ip
  }
  agent_config {
    are_all_plugins_disabled = true
    is_management_disabled   = true
    is_monitoring_disabled   = true
  }

  metadata = {
    ssh_authorized_keys = file(var.pub_key_path)
  }

  # Terraform does not wait for ssh connectivity so we do that by running a simple command using remote-exec before
  # running ansible
  connection {
    type        = "ssh"
    user        = var.user
    private_key = file(var.pvt_key_path)
    host        = self.private_ip
  }

  provisioner "remote-exec" {
    inline = [
      "ls"
    ]
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ${var.user} -i '${self.private_ip},' --private-key ${var.pvt_key_path} -e provision_task_path=${var.ansible_repo_path}/cloud/tasks/provision.yml ${var.ansible_repo_path}/${var.ansible_playbook_name}"
  }
}