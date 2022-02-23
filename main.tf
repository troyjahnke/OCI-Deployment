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
variable "search_display_name" {
  default = "search"
}
variable "dns_display_name" {
  default = "dns"
}
variable "search_ip" {
  default = "10.0.10.2"
}
variable "dns_ip" {
  default = "10.0.10.3"
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

module "instance" {
  source = "./oci-free"
  compartment_ocid = var.compartment_ocid
  ansible_repo_path = "${var.ansible_repo_path}"
  pub_key_path = var.pub_key_path
  pvt_key_path = var.pvt_key_path
  subnet_id = var.subnet_id
  display_name = var.search_display_name
  ip = var.search_ip
}

module "dns" {
  source = "./oci-free"
  compartment_ocid = var.compartment_ocid
  ansible_repo_path = "${var.ansible_repo_path}"
  pub_key_path = var.pub_key_path
  pvt_key_path = var.pvt_key_path
  subnet_id = var.subnet_id
  display_name = var.dns_display_name
  ip = var.dns_ip
}