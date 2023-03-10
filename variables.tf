variable "compartment_id" {}
variable "config_file_profile" {}
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
variable "cert_directory" {}
variable "git_key" {}
variable "vcn_display_name" {}
variable "vcn_cidr_blocks" {}
variable "subnet_cidr_block" {}
variable "container_registries" {}
variable "cpes" {}
variable "drg_display_name" {}
variable "ig_display_name" {}
variable "subnet_display_name" {}
variable "ansible_playbook_name" {}
variable "user" {
  default = "opc"
}
variable "ig_enabled" {
  default = true
}
variable "wireguard_port" {
  default = 51820
}
variable "vpn_routes" {}
variable "personal_networks" {}
variable "work_networks" {}
variable "iot_networks" {}