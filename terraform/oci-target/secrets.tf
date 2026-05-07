resource "oci_kms_vault" "main" {
  compartment_id = var.compartment_id
  display_name   = "${local.name}-vault"
  vault_type     = "DEFAULT"
  freeform_tags  = local.tags
}

resource "oci_kms_key" "main" {
  compartment_id      = var.compartment_id
  display_name        = "${local.name}-key"
  management_endpoint = oci_kms_vault.main.management_endpoint
  freeform_tags       = local.tags

  key_shape {
    algorithm = "AES"
    length    = 32
  }
}
