variable "display_name" {}
variable "subnet_id" {}
variable "ansible_repo_path" {}
variable "pub_key_path" {}
variable "pvt_key_path" {}
variable "ip" {}
variable "compartment_ocid" {}
variable "ansible_playbook_name" {
  default = "terraform-provision.yml"
}
variable "availability_domain" {
  default = "HGGq:PHX-AD-3"
}
variable "user" {
  default = "opc"
}
variable "instance_shape" {
  default = "VM.Standard.E2.1.Micro"
}
variable "image_id" {
  default = "ocid1.image.oc1.phx.aaaaaaaaoo6eyftn234dc3hwobpxzbqkuifsq4kmm4ubtyx5gbtp2xw7xmpa"
}
