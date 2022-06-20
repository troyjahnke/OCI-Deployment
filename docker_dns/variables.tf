# Public variables
variable "cloudflared_version" {
  default = "2022.6.2"
}
variable "pihole_version" {
  default = "2022.05"
}
variable "tz" {
  default = "America/Denver"
}

# Private variables
variable "docker_host" {}
variable "pihole_password" {}
variable "pvt_key_path" {}
