locals {
  services = {
    catalog = {
      image = "${var.image_registry}/catalog-service:0.1.0"
      port  = 8081
    }
    pricing = {
      image = "${var.image_registry}/pricing-service:0.1.0"
      port  = 8082
    }
    assortment_ui = {
      image = "${var.image_registry}/assortment-ui-service:0.1.0"
      port  = 8080
    }
  }

  common_labels = {
    environment = var.environment
    domain      = "fashion-commerce"
    managed_by  = "terraform"
  }
}

resource "kubernetes_namespace_v1" "fashion_demo" {
  metadata {
    name   = var.namespace
    labels = local.common_labels
  }
}

# Placeholder only: real deployment resources should be implemented through the
# customer-approved Kubernetes, Helm, or ArgoCD module pattern.
output "service_images" {
  value = { for name, service in local.services : name => service.image }
}
