# Public variables
variable "cloudflared_version" {
  default = "2022.9.0-amd64"
}
variable "pihole_version" {
  default = "2022.09.3"
}
variable "tz" {
  default = "America/Denver"
}

# Private variables
variable "docker_host" {}
variable "pihole_password" {}
variable "pvt_key_path" {}
