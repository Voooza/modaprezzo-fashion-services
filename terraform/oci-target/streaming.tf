resource "oci_streaming_stream_pool" "main" {
  compartment_id = var.compartment_id
  name           = "${local.name}-stream-pool"
  freeform_tags  = local.tags

  kafka_settings {
    auto_create_topics_enable = false
    log_retention_hours       = 24
    num_partitions            = 1
  }

  private_endpoint_settings {
    subnet_id = oci_core_subnet.streaming_private_endpoint.id
  }
}

resource "oci_streaming_stream" "events" {
  for_each = local.streams

  name               = each.value
  partitions         = 1
  retention_in_hours = 24
  stream_pool_id     = oci_streaming_stream_pool.main.id
  freeform_tags      = local.tags
}
