# Deployment Shape

The Helm chart in `deploy/helm/modaprezzo` is the shared deployment contract for local Kubernetes and OCI Kubernetes Engine.

## Local Kubernetes

Use a local Kubernetes cluster such as `kind`, `k3d`, or `minikube`, plus local Oracle Database Free and Kafka services. Build images with the same Dockerfiles used for OCI and tag them for the local registry:

```bash
podman build -t localhost:5000/modaprezzo/catalog-service:local catalog-service
podman build -t localhost:5000/modaprezzo/pricing-service:local pricing-service
podman build -t localhost:5000/modaprezzo/assortment-ui-service:local assortment-ui-service
helm upgrade --install modaprezzo deploy/helm/modaprezzo -f deploy/helm/modaprezzo/values-local.yaml
```

The local values file uses the same service environment variables as OCI, but points at local Oracle and Kafka endpoints.

## OCI Kubernetes Engine

For OKE, keep the chart the same and supply OCI-specific values:

```bash
helm upgrade --install modaprezzo deploy/helm/modaprezzo -f deploy/helm/modaprezzo/values-oci.yaml
```

Before deploying to OCI, replace the example OCIR registry, Exadata connection service, Kafka-compatible OCI Streaming bootstrap endpoint, ingress class, hostname, and externally managed secret references.

Production secrets should be injected from OCI Vault or the customer-approved secret-management pattern, not committed to Git.
