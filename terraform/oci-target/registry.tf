resource "oci_artifacts_container_repository" "services" {
  for_each = local.service_repositories

  compartment_id = var.compartment_id
  display_name   = "${var.name_prefix}/${each.key}"
  is_immutable   = false
  is_public      = false
  freeform_tags  = local.tags
}
