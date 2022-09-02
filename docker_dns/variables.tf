# Public variables
variable "cloudflared_version" {
  default = "2022.8.4-amd64"
}
variable "pihole_version" {
  default = "2022.09.1"
}
variable "tz" {
  default = "America/Denver"
}

# Private variables
variable "docker_host" {}
variable "pihole_password" {}
variable "pvt_key_path" {}
