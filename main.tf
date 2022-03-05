provider "oci" {
  tenancy_ocid     = var.compartment_id
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.oci_private_key_path
  region           = var.region
}

resource "oci_core_vcn" "vcn" {
  #Required
  compartment_id = var.compartment_id

  #Optional
  cidr_blocks  = var.vcn_cidr_blocks
  display_name = var.vcn_display_name
}

resource "oci_core_subnet" "subnet" {
  #Required
  cidr_block     = var.subnet_cidr_block
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
}

resource "oci_core_drg" "drg" {
  #Required
  compartment_id = var.compartment_id

  #Optional
  display_name = var.drg_display_name
}

resource "oci_core_internet_gateway" "ig" {
  #Required
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id

  #Optional
  enabled      = var.ig_enabled
  display_name = var.ig_display_name
}

resource "oci_core_default_route_table" "route_table" {
  #Required
  compartment_id             = var.compartment_id
  manage_default_resource_id = oci_core_vcn.vcn.default_route_table_id

  route_rules {
    network_entity_id = oci_core_internet_gateway.ig.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }

  dynamic "route_rules" {
    for_each = toset(flatten([for s in var.cpes : s["routes"]]))
    content {
      #Required
      network_entity_id = oci_core_drg.drg.id
      #Optional
      destination       = route_rules.key
      destination_type  = "CIDR_BLOCK"
    }
  }
}

resource "oci_core_drg_attachment" "drg_attachment" {
  #Required
  drg_id       = oci_core_drg.drg.id
  display_name = "${var.drg_display_name}-Attachment"
  network_details {
    id   = oci_core_vcn.vcn.id
    type = "VCN"
  }
}

resource "oci_core_cpe" "cpe" {
  for_each       = var.cpes
  #Required
  compartment_id = var.compartment_id
  ip_address     = each.value["ip"]
  #Optional
  display_name   = each.key
}

resource "oci_core_ipsec" "ipsec" {
  for_each = var.cpes

  #Required
  compartment_id = var.compartment_id
  cpe_id         = oci_core_cpe.cpe[each.key].id
  drg_id         = oci_core_drg.drg.id
  static_routes  = each.value["routes"]

  #Optional
  display_name = "VPN-${each.key}"
}

data "oci_core_ipsec_connection_tunnels" "tunnels" {
  for_each = var.cpes
  #Required
  ipsec_id = oci_core_ipsec.ipsec[each.key].id
}

resource "oci_core_ipsec_connection_tunnel_management" "test_ip_sec_connection_tunnel" {
  for_each = var.cpes
  #Required
  ipsec_id = oci_core_ipsec.ipsec[
  each.key
  ].id
  tunnel_id = data.oci_core_ipsec_connection_tunnels.tunnels[each.key].ip_sec_connection_tunnels[
  0
  ].id
  routing = "STATIC"

  #  shared_secret = var.ip_sec_connection_tunnel_management_shared_secret
  ike_version = "V2"
}

resource "oci_core_instance" "free_instance" {
  depends_on = [oci_core_default_route_table.route_table]
  for_each   = var.instances

  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  shape               = var.instance_shape
  display_name        = each.key

  create_vnic_details {
    assign_public_ip = true
    subnet_id        = oci_core_subnet.subnet.id
    private_ip       = each.value
  }

  source_details {
    source_type = "image"
    source_id   = var.image_id
  }

  agent_config {
    are_all_plugins_disabled = true
    is_management_disabled   = true
    is_monitoring_disabled   = true
  }

  metadata = {
    ssh_authorized_keys = file(var.pub_key_path)
  }

  # Terraform does not wait for ssh connectivity so we do that by running a simple command using remote-exec before
  # running ansible
  connection {
    type        = "ssh"
    user        = var.user
    private_key = file(var.pvt_key_path)
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "ls"
    ]
  }
}

resource "null_resource" "ansible" {
  provisioner "local-exec" {
    command     = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ${var.user} -i ${join(",", [for instance in oci_core_instance.free_instance: instance.public_ip])} --private-key ${var.pvt_key_path} ${var.ansible_playbook_name} -e deployment_user=${var.user} -e cert_directory=${var.cert_directory}"
    working_dir = var.ansible_repo_path
  }
}

resource "oci_artifacts_container_repository" "container_repository" {
  for_each       = toset(var.container_registries)
  #Required
  compartment_id = var.compartment_id
  display_name   = each.key
  #Optional
  is_immutable   = false
  is_public      = false
}

terraform {
  backend "s3" {
    bucket                      = "terraform"
    key                         = "terraform/terraform.tfstate"
    region                      = "us-phoenix-1"
    endpoint                    = "https://axe3byclj986.compat.objectstorage.us-phoenix-1.oraclecloud.com"
    shared_credentials_file     = "./backend_creds"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}