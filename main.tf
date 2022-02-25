variable "compartment_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "oci_private_key_path" {}
variable "region" {}
variable "availability_domain" {}
variable "instance_shape" {}
variable "image_id" {}
variable "subnet_id" {}
variable "ansible_repo_path" {}
variable "pub_key_path" {}
variable "pvt_key_path" {}
variable "instances" {}

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

module "oci-free" {
  source = "./oci-free"
  compartment_ocid = var.compartment_ocid
  ansible_repo_path = "${var.ansible_repo_path}"
  pub_key_path = var.pub_key_path
  pvt_key_path = var.pvt_key_path
  subnet_id = var.subnet_id
  for_each = {for name, ip in var.instances: name => ip}
  display_name = each.key
  ip = each.value
}