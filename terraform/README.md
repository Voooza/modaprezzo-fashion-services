# Terraform

This directory captures the infrastructure-as-code shape for deploying the demonstrator to an OCI-hosted Kubernetes target.

The current files are placeholders and design notes, not production-ready modules. They describe how we would structure Terraform for a real D:Suite migration engagement once tenancy, network, security, registry, and platform standards are confirmed.

## Proposed Scope

- OCI compartment, tagging, and policy references.
- OKE workload namespace and service-account setup.
- Container image repository references.
- Kafka-compatible messaging, mapped either to customer platform Kafka or OCI Streaming with a compatibility layer.
- Kubernetes deployment, service, ingress, and horizontal pod autoscaler resources.
- Secrets integration through the approved customer secret store.
- Observability annotations for Prometheus, Grafana dashboards, OpenSearch logs, and Jaeger tracing.

## Delivery Approach

1. Confirm the existing OCI and OKE landing zone with the customer platform team.
2. Keep reusable platform modules separate from application deployment modules.
3. Use GitLab CI to run `terraform fmt`, `terraform validate`, static checks, plan generation, and approval-gated apply.
4. Promote the same service artifacts through dev, test, acceptance, and production by changing environment variables and secrets, not application code.
5. Let ArgoCD own Kubernetes application reconciliation where this matches the target platform model.

## Open Inputs

- OCI tenancy and compartment structure.
- OKE cluster ownership and namespace provisioning process.
- Container registry naming and vulnerability-scanning requirements.
- Approved event platform: Kafka, OCI Streaming, or another managed broker.
- Ingress, service mesh, TLS, WAF, and network-policy standards.
- Secrets management and key management requirements.
