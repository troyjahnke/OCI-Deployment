terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

provider "docker" {
  host     = var.docker_host
  ssh_opts = ["-i", var.pvt_key_path]
}

resource "docker_image" "adguard" {
  name = "adguard/adguardhome:${var.adguard_version}"
}

resource "docker_volume" "adguard" {
  for_each = toset(["adguard-data", "adguard-conf"])
  name     = each.key
}

resource "docker_container" "adguard" {
  image        = docker_image.adguard.image_id
  name         = "adguard"
  network_mode = "host"
  restart      = "unless-stopped"
  volumes {
    container_path = "/opt/adguardhome/work"
    volume_name    = docker_volume.adguard["adguard-data"].name
  }
  volumes {
    container_path = "/opt/adguardhome/conf"
    volume_name    = docker_volume.adguard["adguard-conf"].name
  }
}

terraform {
  backend "s3" {
    bucket                      = "terraform"
    key                         = "terraform/docker_dns.tfstate"
    region                      = "us-phoenix-1"
    endpoint                    = "https://axe3byclj986.compat.objectstorage.us-phoenix-1.oraclecloud.com"
    shared_credentials_file     = "~/.oci/aws_creds"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}

