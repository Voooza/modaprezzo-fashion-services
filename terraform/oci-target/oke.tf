resource "oci_containerengine_cluster" "main" {
  compartment_id     = var.compartment_id
  kubernetes_version = var.kubernetes_version
  name               = "${local.name}-oke"
  vcn_id             = oci_core_vcn.main.id
  freeform_tags      = local.tags

  cluster_pod_network_options {
    cni_type = "OCI_VCN_IP_NATIVE"
  }

  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = oci_core_subnet.oke_api.id
  }

  options {
    service_lb_subnet_ids = [oci_core_subnet.load_balancer.id]
  }
}

data "oci_containerengine_node_pool_option" "selected" {
  compartment_id        = var.compartment_id
  node_pool_option_id   = oci_containerengine_cluster.main.id
  node_pool_k8s_version = var.kubernetes_version
  node_pool_os_arch     = local.node_pool_os_arch
  node_pool_os_type     = "OL8"
}

locals {
  node_pool_sources = [
    for source in data.oci_containerengine_node_pool_option.selected.sources : source
    if !strcontains(source.source_name, "GPU")
  ]
  node_pool_source = local.node_pool_sources[0]
}

resource "oci_containerengine_node_pool" "main" {
  cluster_id         = oci_containerengine_cluster.main.id
  compartment_id     = var.compartment_id
  kubernetes_version = var.kubernetes_version
  name               = "${local.name}-pool"
  node_shape         = var.node_shape
  freeform_tags      = local.tags
  node_metadata      = var.ssh_public_key == "" ? {} : { ssh_authorized_keys = var.ssh_public_key }

  node_shape_config {
    ocpus         = var.node_ocpus
    memory_in_gbs = var.node_memory_gbs
  }

  node_source_details {
    image_id    = local.node_pool_source.image_id
    source_type = local.node_pool_source.source_type
  }

  node_config_details {
    size = var.node_count

    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      subnet_id           = oci_core_subnet.workers.id
    }

    node_pool_pod_network_option_details {
      cni_type          = "OCI_VCN_IP_NATIVE"
      max_pods_per_node = 31
      pod_subnet_ids    = [oci_core_subnet.pods.id]
    }
  }
}
