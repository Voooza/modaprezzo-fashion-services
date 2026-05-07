locals {
  name = "${var.name_prefix}-${var.environment}"

  tags = {
    application = "modaprezzo"
    environment = var.environment
    managed_by  = "terraform"
    domain      = "fashion-commerce"
  }

  service_repositories = toset([
    "catalog-service",
    "pricing-service",
    "assortment-ui-service",
  ])

  streams = {
    product_published = "fashion.product.published.v1"
    price_changed     = "fashion.price.changed.v1"
    assortment_launch = "fashion.assortment.launched.v1"
  }

  node_pool_os_arch = contains(["VM.Standard.A1.Flex", "BM.Standard.A1.160"], var.node_shape) ? "AARCH64" : "X86_64"
}
