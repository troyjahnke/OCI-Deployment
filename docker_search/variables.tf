# Public variables
variable "traefik_version" {
  default = "v2.9.5"
}
variable "whoogle_version" {
  default = "0.8.0"
}
variable "tz" {
  default = "America/Denver"
}
variable "whoogle_language" {
  default = "lang_en"
}
variable "whoogle_country" {
  default = "US"
}

# Private variables
variable "docker_host" {}
variable "search_labels" {}
variable "cert_path" {}
variable "traefik_config_path" {}
variable "pvt_key_path" {}
variable "whoogle_config_url" {}
