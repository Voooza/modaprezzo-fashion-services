variable "environment" {
  description = "Target environment, for example dev, test, acceptance, or prod."
  type        = string
  default     = "dev"
}

variable "namespace" {
  description = "Kubernetes namespace for the fashion demonstrator services."
  type        = string
  default     = "fashion-demo"
}

variable "image_registry" {
  description = "Container registry hosting the built service images."
  type        = string
  default     = "replace-with-approved-registry.example.com/modaprezzo"
}
