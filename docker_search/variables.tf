# Public variables
variable "traefik_version" {
  default = "v2.6.3"
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