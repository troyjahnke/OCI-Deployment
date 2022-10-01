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

resource "docker_image" "pihole" {
  name = "pihole/pihole:${var.pihole_version}"
}

resource "docker_image" "cloudflared" {
  name = "cloudflare/cloudflared:${var.cloudflared_version}"
}

resource "docker_volume" "pihole" {
  for_each = toset(["pihole-config", "pihole-dnsmasq-config"])
  name     = each.key
}

resource "docker_container" "cloudflared" {
  image        = docker_image.cloudflared.image_id
  name         = "cloudflared"
  network_mode = "host"
  restart      = "unless-stopped"
  command      = ["proxy-dns", "--port", "5053"]
}

resource "docker_container" "pihole" {
  image        = docker_image.pihole.image_id
  name         = "pihole"
  network_mode = "host"
  restart      = "unless-stopped"
  env = [
    "TZ=${var.tz}",
    "PIHOLE_DNS_=;127.0.0.1#5053",
    "WEBPASSWORD=${var.pihole_password}",
    "DNSMASQ_LISTENING=all",
    "DNSMASQ_USER=root"
  ]
  volumes {
    container_path = "/etc/pihole/"
    volume_name    = docker_volume.pihole["pihole-config"].name
  }
  volumes {
    container_path = "/etc/dnsmasq.d/"
    volume_name    = docker_volume.pihole["pihole-dnsmasq-config"].name
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

