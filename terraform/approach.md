# What We Do With Terraform

We use Terraform to make cloud and platform changes reviewable, repeatable, and auditable.

For this demonstrator, Terraform represents the deployment contract around the three fashion-domain services: where they run, how they are configured, how they communicate, and how operations teams observe them. In a real customer D:Suite engagement, the modules would be connected to the existing OCI landing zone and delivery pipeline rather than creating isolated infrastructure from scratch.

## Engineering Principles

- Keep infrastructure changes in Git with merge-request review.
- Separate shared platform concerns from service-specific deployment concerns.
- Generate plans for every environment and require approval before applying to controlled environments.
- Store secrets outside Terraform state whenever possible.
- Prefer customer-approved modules and provider versions.
- Include tagging, ownership, and cost-allocation metadata from the beginning.

## Example Module Boundaries

- `platform-foundation`: compartments, policies, network references, and shared provider configuration.
- `workload-namespace`: Kubernetes namespace, service accounts, quotas, network policies, and mesh annotations.
- `eventing`: topic/stream declarations for product, price, and assortment events.
- `service-deployment`: deployment, service, ingress, config maps, autoscaling, and observability labels per microservice.

## Why This Matters For The RFP

The RFP calls out OCI, Kubernetes, Docker, Terraform, Ansible, GitLab CI/CD, ArgoCD, observability, and service-mesh operations. This structure demonstrates that we can work in that target architecture while keeping enough separation to integrate with customer-owned platform standards.
