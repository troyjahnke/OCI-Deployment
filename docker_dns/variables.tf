# Public variables
variable "cloudflared_version" {
  default = "2022.10.3-amd64"
}
variable "pihole_version" {
  default = "2022.11.1"
}
variable "tz" {
  default = "America/Denver"
}

# Private variables
variable "docker_host" {}
variable "pihole_password" {}
variable "pvt_key_path" {}
