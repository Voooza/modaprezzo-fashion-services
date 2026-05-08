terraform {
  required_version = ">= 1.12.0"

  backend "oci" {
    bucket              = "modaprezzo-dev-terraform-state"
    namespace           = "frtcaobwa51v"
    key                 = "oci-target/terraform.tfstate"
    region              = "eu-frankfurt-1"
    auth                = "APIKey"
    config_file_profile = "DEFAULT"
  }

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 7.0"
    }
  }
}

provider "oci" {
  region              = var.region
  auth                = var.oci_auth
  config_file_profile = var.oci_config_profile
}
