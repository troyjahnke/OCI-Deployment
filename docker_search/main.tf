terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
    }
  }
}

provider "docker" {
  host = var.docker_host
  ssh_opts = ["-i", var.pvt_key_path]
}
resource "docker_network" "search" {
  name = "search"
}

resource "docker_image" "traefik" {
  name = "traefik:${var.traefik_version}"
}
resource "docker_image" "searxng" {
  name = "searxng/searxng:latest"
}

resource "docker_container" "traefik" {
  image = docker_image.traefik.latest
  networks_advanced {
    name = docker_network.search.name
  }
  name  = "traefik"
  restart = "unless-stopped"

  command = [
      # "--log.level=DEBUG",
      "--api.insecure=true",
      "--providers.docker=true",
      "--providers.docker.exposedbydefault=false",
      "--entrypoints.https.address=:443",
      "--providers.file.directory=/config/"
  ]
  volumes {
    container_path = "/var/run/docker.sock"
    host_path = "/var/run/docker.sock"
  }
  volumes {
    host_path = var.cert_path
    container_path = "/certs"
  }
  volumes {
    host_path = var.traefik_config_path
    container_path = "/config"
  }

  dynamic "ports" {
    for_each = toset(["443", "8080"])
    content {
      internal = ports.key
      external = ports.key
      protocol = "tcp"
    }
  }
}
resource "docker_container" "searxng" {
  image = docker_image.searxng.latest
  networks_advanced {
    name = docker_network.search.name
  }
  name  = "searxng"
  restart = "unless-stopped"

  dynamic "labels" {
    for_each = var.search_labels
    content {
      label = labels.key
      value = labels.value
    }
  }
}

terraform {
  backend "s3" {
    bucket                      = "terraform"
    key                         = "terraform/docker_search.tfstate"
    region                      = "us-phoenix-1"
    endpoint                    = "https://axe3byclj986.compat.objectstorage.us-phoenix-1.oraclecloud.com"
    shared_credentials_file     = "~/.oci/aws_creds"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}