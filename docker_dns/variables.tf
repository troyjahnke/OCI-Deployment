# Public variables
variable "cloudflared_version" {
  default = "2022.8.2-amd64"
}
variable "pihole_version" {
  default = "2022.07.1"
}
variable "tz" {
  default = "America/Denver"
}

# Private variables
variable "docker_host" {}
variable "pihole_password" {}
variable "pvt_key_path" {}
