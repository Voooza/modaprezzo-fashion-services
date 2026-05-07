variable "region" {
  description = "OCI region identifier, for example eu-frankfurt-1."
  type        = string
}

variable "oci_auth" {
  description = "OCI Terraform provider auth mode. Use SecurityToken after running oci session authenticate, or ApiKey for long-lived API key auth."
  type        = string
  default     = "SecurityToken"
}

variable "oci_config_profile" {
  description = "OCI CLI config profile used by the Terraform provider."
  type        = string
  default     = "DEFAULT"
}

variable "compartment_id" {
  description = "Compartment OCID where the demo platform resources are provisioned."
  type        = string
}

variable "name_prefix" {
  description = "Prefix used for OCI resource names."
  type        = string
  default     = "modaprezzo"
}

variable "environment" {
  description = "Deployment environment label."
  type        = string
  default     = "dev"
}

variable "kubernetes_version" {
  description = "OKE Kubernetes version. Use an active version available in the selected region."
  type        = string
  default     = "v1.31.1"
}

variable "node_shape" {
  description = "OKE worker node shape. VM.Standard.E4.Flex matches common amd64 enterprise images; VM.Standard.A1.Flex can be used for cost-conscious arm64 demos."
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "node_count" {
  description = "Number of worker nodes in the initial node pool."
  type        = number
  default     = 3
}

variable "node_ocpus" {
  description = "OCPUs per worker node when using a flexible shape."
  type        = number
  default     = 1
}

variable "node_memory_gbs" {
  description = "Memory per worker node when using a flexible shape."
  type        = number
  default     = 8
}

variable "ssh_public_key" {
  description = "Optional SSH public key for worker-node troubleshooting."
  type        = string
  default     = ""
}

variable "allowed_admin_cidrs" {
  description = "CIDR ranges allowed to reach the public OKE API endpoint."
  type        = list(string)
  default     = []
}

variable "existing_database_connect_string" {
  description = "JDBC connect string for the target Oracle Database service, for example an Exadata high service with wallet configuration."
  type        = string
  default     = "jdbc:oracle:thin:@replace-with-exadata-service-name_high?TNS_ADMIN=/etc/oracle/wallet"
}

variable "database_wallet_secret_name" {
  description = "Kubernetes secret name expected to contain the Oracle wallet files, if wallet-based TLS is required."
  type        = string
  default     = "modaprezzo-db-wallet"
}

variable "database_password_secret_name" {
  description = "Kubernetes secret name expected to contain catalog-password and pricing-password."
  type        = string
  default     = "modaprezzo-db"
}
