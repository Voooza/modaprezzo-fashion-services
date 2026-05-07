# The target architecture expects Oracle Database to be a managed OCI database
# service rather than a database pod in Kubernetes. For the customer target this
# is expected to be Exadata Database Service or an equivalent customer-provided
# Oracle database service. This stack keeps the database lifecycle separate and
# exposes the connection contract needed by the services.

locals {
  database_contract = {
    jdbc_url                 = var.existing_database_connect_string
    password_secret_name     = var.database_password_secret_name
    wallet_secret_name       = var.database_wallet_secret_name
    service_owned_schemas    = ["catalog_app", "pricing_app"]
    migration_tool           = "Flyway"
    application_secret_store = oci_kms_vault.main.id
  }
}
