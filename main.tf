variable "compartment_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "oci_private_key_path" {}
variable "region" {}
variable "availability_domain" {}
variable "search_display_name" {}
variable "instance_shape" {}
variable "image_id" {}
variable "subnet_id" {}
variable "ansible_repo_path" {}
variable "pub_key_path" {}
variable "pvt_key_path" {}
variable "search_ip" {}
variable "ansible_playbook_name" {
  default = "terraform-provision.yml"
}
variable "user" {
  default = "opc"
}

provider "oci" {
  tenancy_ocid     = var.compartment_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.oci_private_key_path
  region           = var.region
}


resource "oci_core_instance" "test" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = var.search_display_name
  shape               = var.instance_shape

  source_details {
    source_type = "image"
    source_id   = var.image_id
  }
  create_vnic_details {
    assign_public_ip = true
    subnet_id        = var.subnet_id
    private_ip       = var.search_ip
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
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ${var.user} -i '${var.search_ip},' --private-key ${var.pvt_key_path} -e provision_task_path=${var.ansible_repo_path}/cloud/tasks/provision.yml ${var.ansible_repo_path}/${var.ansible_playbook_name}"
  }
}