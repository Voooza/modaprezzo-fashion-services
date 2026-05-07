# OCI Target Architecture Stack

This Terraform stack models the target OCI shape for the ModaPrezzo demonstrator:

- OCI VCN with public ingress and private worker/pod/service subnets.
- OKE cluster with OCI VCN-native pod networking.
- Private OCIR repositories for service images.
- OCI Streaming stream pool with Kafka compatibility enabled.
- Explicit streams for product, price, and assortment events.
- OCI Vault and a KMS key for application secrets.
- External Oracle Database connection contract for Exadata Database Service or an approved managed Oracle Database target.

The application containers run on OKE. Oracle Database runs as a managed database service and is accessed through JDBC from the services.

The OKE worker image is resolved from OCI node-pool options for the selected Kubernetes version, OS family, and CPU architecture. This keeps the stack from pinning a region-specific image OCID in source control.

## Why Database Is A Contract Here

Exadata Database Service is normally provisioned through a customer platform or database team and carries cost, capacity, network, backup, security, and operational decisions beyond this small demo stack. The correct target pattern is to keep the database lifecycle separate and provide the application team with:

- JDBC connect string.
- Service-owned schemas such as `catalog_app` and `pricing_app`.
- Wallet or TLS material if required.
- Passwords or wallet files delivered through OCI Vault and Kubernetes secrets.
- Backup, restore, patching, and monitoring ownership.

For a free-trial demo, this contract can point to Autonomous Database or another approved Oracle Database service. For the RFP target, it should point to Exadata Database Service or the customer-provided equivalent.

## Apply Flow

1. Configure OCI CLI credentials or run this from OCI Cloud Shell.
2. Create `terraform.tfvars` with at least:

   ```hcl
   region         = "eu-frankfurt-1"
   compartment_id = "ocid1.compartment.oc1..replace"
   oci_auth       = "SecurityToken"
   ```

   Use `SecurityToken` after `oci session authenticate`. Use `ApiKey` when the OCI config profile uses an uploaded API signing key.

3. Initialize and plan:

   ```bash
   terraform init
   terraform plan
   ```

4. Apply after reviewing cost and quota impact:

   ```bash
   terraform apply
   ```

5. Configure `kubectl` for the generated OKE cluster, push images to OCIR, create the runtime Kubernetes secrets from OCI Vault values, then deploy the Helm chart.

## Cost Guardrails

- The default worker shape is `VM.Standard.E5.Flex`, which is a pragmatic amd64 target for enterprise container images.
- To minimize free-trial spend, override `node_shape = "VM.Standard.A1.Flex"` and use arm64 service images.
- A1 capacity is not guaranteed in every availability domain. If OCI returns `Out of host capacity`, either retry later, use a capacity reservation, or switch to a paid flexible shape such as `VM.Standard.E5.Flex`.
- OKE, load balancers, NAT gateways, Streaming, and database services can consume trial credits depending on region and configuration.
- Review the OCI cost estimate before `apply`.
- Use a dedicated compartment and budget alert for this demo.
