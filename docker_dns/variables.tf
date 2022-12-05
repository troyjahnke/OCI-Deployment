# Public variables
variable "adguard_version"{
  default = "v0.107.19"
}
variable "tz" {
  default = "America/Denver"
}

# Private variables
variable "docker_host" {}
variable "pihole_password" {}
variable "pvt_key_path" {}
