data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

resource "oci_core_vcn" "main" {
  compartment_id = var.compartment_id
  display_name   = "${local.name}-vcn"
  cidr_blocks    = ["10.40.0.0/16"]
  dns_label      = "modaprezzo"
  freeform_tags  = local.tags
}

resource "oci_core_internet_gateway" "main" {
  compartment_id = var.compartment_id
  display_name   = "${local.name}-igw"
  vcn_id         = oci_core_vcn.main.id
  enabled        = true
  freeform_tags  = local.tags
}

resource "oci_core_nat_gateway" "main" {
  compartment_id = var.compartment_id
  display_name   = "${local.name}-nat"
  vcn_id         = oci_core_vcn.main.id
  freeform_tags  = local.tags
}

resource "oci_core_service_gateway" "main" {
  compartment_id = var.compartment_id
  display_name   = "${local.name}-sgw"
  vcn_id         = oci_core_vcn.main.id
  freeform_tags  = local.tags

  services {
    service_id = data.oci_core_services.all_oci_services.services[0].id
  }
}

data "oci_core_services" "all_oci_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_id
  display_name   = "${local.name}-public-rt"
  vcn_id         = oci_core_vcn.main.id
  freeform_tags  = local.tags

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.main.id
  }
}

resource "oci_core_route_table" "private" {
  compartment_id = var.compartment_id
  display_name   = "${local.name}-private-rt"
  vcn_id         = oci_core_vcn.main.id
  freeform_tags  = local.tags

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.main.id
  }

  route_rules {
    destination       = data.oci_core_services.all_oci_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.main.id
  }
}

resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_id
  display_name   = "${local.name}-public-sl"
  vcn_id         = oci_core_vcn.main.id
  freeform_tags  = local.tags

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 443
    }
  }

  dynamic "ingress_security_rules" {
    for_each = length(var.allowed_admin_cidrs) == 0 ? ["0.0.0.0/0"] : var.allowed_admin_cidrs
    content {
      protocol = "6"
      source   = ingress_security_rules.value
      tcp_options {
        min = 6443
        max = 6443
      }
    }
  }
}

resource "oci_core_security_list" "private" {
  compartment_id = var.compartment_id
  display_name   = "${local.name}-private-sl"
  vcn_id         = oci_core_vcn.main.id
  freeform_tags  = local.tags

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "all"
    source   = oci_core_vcn.main.cidr_blocks[0]
  }
}

resource "oci_core_subnet" "oke_api" {
  compartment_id             = var.compartment_id
  display_name               = "${local.name}-oke-api-subnet"
  vcn_id                     = oci_core_vcn.main.id
  cidr_block                 = "10.40.0.0/28"
  route_table_id             = oci_core_route_table.public.id
  security_list_ids          = [oci_core_security_list.public.id]
  prohibit_public_ip_on_vnic = false
  dns_label                  = "okeapi"
  freeform_tags              = local.tags
}

resource "oci_core_subnet" "load_balancer" {
  compartment_id             = var.compartment_id
  display_name               = "${local.name}-lb-subnet"
  vcn_id                     = oci_core_vcn.main.id
  cidr_block                 = "10.40.1.0/24"
  route_table_id             = oci_core_route_table.public.id
  security_list_ids          = [oci_core_security_list.public.id]
  prohibit_public_ip_on_vnic = false
  dns_label                  = "lb"
  freeform_tags              = local.tags
}

resource "oci_core_subnet" "workers" {
  compartment_id             = var.compartment_id
  display_name               = "${local.name}-worker-subnet"
  vcn_id                     = oci_core_vcn.main.id
  cidr_block                 = "10.40.10.0/24"
  route_table_id             = oci_core_route_table.private.id
  security_list_ids          = [oci_core_security_list.private.id]
  prohibit_public_ip_on_vnic = true
  dns_label                  = "workers"
  freeform_tags              = local.tags
}

resource "oci_core_subnet" "pods" {
  compartment_id             = var.compartment_id
  display_name               = "${local.name}-pod-subnet"
  vcn_id                     = oci_core_vcn.main.id
  cidr_block                 = "10.40.20.0/22"
  route_table_id             = oci_core_route_table.private.id
  security_list_ids          = [oci_core_security_list.private.id]
  prohibit_public_ip_on_vnic = true
  dns_label                  = "pods"
  freeform_tags              = local.tags
}

resource "oci_core_subnet" "streaming_private_endpoint" {
  compartment_id             = var.compartment_id
  display_name               = "${local.name}-streaming-subnet"
  vcn_id                     = oci_core_vcn.main.id
  cidr_block                 = "10.40.30.0/24"
  route_table_id             = oci_core_route_table.private.id
  security_list_ids          = [oci_core_security_list.private.id]
  prohibit_public_ip_on_vnic = true
  dns_label                  = "streaming"
  freeform_tags              = local.tags
}
