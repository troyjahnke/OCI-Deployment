# Public variables
variable "traefik_version" {
  default = "v2.7.1"
}
variable whoogle_version{
  default = "0.7.4"
}
variable "tz" {
  default = "America/Denver"
}

# Private variables
variable "docker_host" {}
variable "search_labels" {}
variable "cert_path" {}
variable "traefik_config_path" {}
variable "pvt_key_path" {}
