output "oke_cluster_id" {
  description = "OKE cluster OCID."
  value       = oci_containerengine_cluster.main.id
}

output "region" {
  description = "OCI region used by this stack."
  value       = var.region
}

output "ocir_repositories" {
  description = "Private OCIR repositories created for service images."
  value = {
    for name, repo in oci_artifacts_container_repository.services :
    name => repo.display_name
  }
}

output "stream_pool_id" {
  description = "OCI Streaming stream pool OCID."
  value       = oci_streaming_stream_pool.main.id
}

output "kafka_bootstrap_servers" {
  description = "Kafka-compatible bootstrap endpoint for the OCI Streaming stream pool."
  value       = "${oci_streaming_stream_pool.main.endpoint_fqdn}:9092"
}

output "streams" {
  description = "OCI Streaming streams created for async service integration."
  value = {
    for key, stream in oci_streaming_stream.events :
    key => stream.name
  }
}

output "vault_id" {
  description = "OCI Vault OCID for application secrets."
  value       = oci_kms_vault.main.id
}

output "database_contract" {
  description = "Database connection contract to feed into Helm or the delivery platform."
  value       = local.database_contract
}
