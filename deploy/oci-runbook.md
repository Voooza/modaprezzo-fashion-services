# OCI Deployment Runbook

This runbook deploys the demonstrator to the managed OCI target shape rather than the single-VM fallback.

## Target Services

- OKE for application workloads.
- OCIR for private service images.
- OCI Streaming with Kafka compatibility for async events.
- OCI Vault for runtime secret material.
- Oracle Database through a managed database service such as Exadata Database Service or Autonomous Database for a trial demonstration.
- Helm for Kubernetes release deployment.

## 1. Provision OCI Platform Resources

Run from OCI Cloud Shell or from a workstation configured with OCI CLI credentials:

```bash
cd terraform/oci-target
terraform init
terraform plan -out out.plan
terraform apply out.plan
```

Minimum `terraform.tfvars`:

```hcl
region         = "eu-frankfurt-1"
compartment_id = "ocid1.compartment.oc1..replace"
```

For a free-trial-friendly worker pool, use ARM nodes and build ARM images:

```hcl
node_shape      = "VM.Standard.A1.Flex"
node_count      = 2
node_ocpus      = 2
node_memory_gbs = 12
```

## 2. Configure kubectl

After Terraform creates OKE, configure Kubernetes access:

```bash
oci ce cluster create-kubeconfig \
  --cluster-id "$(terraform output -raw oke_cluster_id)" \
  --file "$HOME/.kube/config" \
  --region "$(terraform output -raw region 2>/dev/null || echo eu-frankfurt-1)" \
  --token-version 2.0.0 \
  --kube-endpoint PUBLIC_ENDPOINT
```

Then verify:

```bash
kubectl get nodes
```

## 3. Push Images To OCIR

Get the tenancy namespace:

```bash
oci os ns get
```

Log in to OCIR with your OCI user name and an auth token:

```bash
podman login <region-key>.ocir.io
```

Build and push images. Use `--platform linux/arm64` when the OKE node pool uses `VM.Standard.A1.Flex`.

```bash
export OCIR=<region-key>.ocir.io/<tenancy-namespace>/modaprezzo
export TAG=0.1.0-SNAPSHOT

podman build --platform linux/amd64 -t "$OCIR/catalog-service:$TAG" catalog-service
podman build --platform linux/amd64 -t "$OCIR/pricing-service:$TAG" pricing-service
podman build --platform linux/amd64 -t "$OCIR/assortment-ui-service:$TAG" assortment-ui-service

podman push "$OCIR/catalog-service:$TAG"
podman push "$OCIR/pricing-service:$TAG"
podman push "$OCIR/assortment-ui-service:$TAG"
```

## 4. Create Runtime Kubernetes Secrets

The chart expects these secrets to already exist in OKE for OCI deployments:

- `modaprezzo-db` with keys `catalog-password` and `pricing-password`.
- `modaprezzo-db-wallet` with Oracle wallet files if wallet-based database connectivity is required.
- `modaprezzo-kafka` with key `sasl-jaas-config` for OCI Streaming Kafka authentication.

Example Kafka secret shape:

```bash
kubectl create secret generic modaprezzo-kafka \
  --from-literal=sasl-jaas-config='org.apache.kafka.common.security.plain.PlainLoginModule required username="<tenancy>/<user>/<stream-pool-ocid>" password="<auth-token>";'
```

For a real customer environment, create these from OCI Vault or the approved secret-management integration rather than from shell literals.

## 5. Deploy The Services

Create an OCI values override from `deploy/helm/modaprezzo/values-oci.yaml`, replacing:

- OCIR registry path.
- Image tag.
- Exadata or Autonomous Database JDBC URL.
- OCI Streaming Kafka bootstrap endpoint.
- Ingress class and hostname.

Then deploy:

```bash
helm upgrade --install modaprezzo deploy/helm/modaprezzo \
  -f deploy/helm/modaprezzo/values-oci.yaml \
  --namespace fashion-demo \
  --create-namespace
```

Verify:

```bash
kubectl get pods -n fashion-demo
kubectl get ingress -n fashion-demo
kubectl logs -n fashion-demo deploy/modaprezzo-catalog-service
```

## 6. Smoke Test

After ingress is ready:

```bash
curl https://<hostname>/api/products/prd-1001
curl https://<hostname>/api/prices/prd-1001/DE
```

The UI should be available at:

```text
https://<hostname>/
```
