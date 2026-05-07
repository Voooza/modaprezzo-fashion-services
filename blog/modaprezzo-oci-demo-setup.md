# Building ModaPrezzo: A Fashion Commerce Demo Walks Into OCI

There is a moment in every demo project where someone says, "This should be simple."

That is usually the exact moment the soundtrack changes.

This post is the story of setting up the ModaPrezzo fashion commerce demonstrator: three Java microservices, a Vaadin UI, REST integration, async messaging, local Podman runtime, Terraform, Helm, OCI Streaming, OCIR, Vault, and OKE. Think of it as "The Fellowship of the Stack", except everyone is wearing seasonal retail inventory and arguing about Kubernetes networking.

## The Cast

The domain is deliberately concrete: selling fashion across markets. No abstract `foo-service`, no lonely `bar-api`. The demo has three services with jobs that make sense:

| Service | Role |
| --- | --- |
| `catalog-service` | Owns products, SKUs, publication status, and seasonal catalog data. |
| `pricing-service` | Owns market prices, promotion readiness, and pricing status. |
| `assortment-ui-service` | A Vaadin merchandiser UI for reviewing catalog and pricing data and launching assortments. |

They integrate in two ways:

- REST APIs for direct reads and workflow calls.
- Kafka-compatible async events for business changes.

The basic flow is:

1. A product is published in the catalog.
2. `catalog-service` emits `fashion.product.published.v1`.
3. `pricing-service` consumes it and prepares pricing.
4. The UI reads catalog and price data over REST.
5. A merchandiser launches an assortment and emits `fashion.assortment.launched.v1`.

It is not production-complete, but it is demonstrable architecture rather than a PowerPoint with a trench coat.

## Local Runtime: "We're Going To Need A Bigger Compose File"

For local development we used:

- Java 21
- Maven
- Spring Boot
- Vaadin
- Oracle Database Free
- Kafka
- Podman on the Windows host
- `docker-compose.yml` from WSL

The compose stack starts:

- Oracle Database Free
- Kafka
- `catalog-service`
- `pricing-service`
- `assortment-ui-service`

The UI runs on port `8080`, with the backend services on `8081` and `8082`.

Maven had a corporate mirror issue, so the repo includes a clean `maven-settings.xml`. That lets the services build without waiting for a mirror that responds like HAL 9000: calm, polite, and absolutely not doing what you need.

## Specs And Scenarios

Each service includes:

- `spec/openapi.yaml`
- `spec/asyncapi.yaml`
- `bdd/*.feature`

This was intentional. The point is not just to show code. It is to show how the team thinks about contracts:

- REST contracts are visible.
- Event contracts are visible.
- BDD scenarios describe business behavior.

In other words: the docs are not sitting in the corner like the last scene of "Citizen Kane", whispering "Rosebud" while everyone ignores them.

## Terraform: The First Map

We created an OCI target Terraform stack under:

```text
terraform/oci-target
```

It models the real target shape:

- VCN
- public and private subnets
- internet gateway
- NAT gateway
- service gateway
- route tables
- security lists
- OKE cluster
- OKE node pool
- OCIR repositories
- OCI Streaming stream pool and streams
- OCI Vault
- KMS key
- database connection contract

The database is intentionally a contract, not a toy database provisioned by the app stack. For a real target, Exadata or an approved managed Oracle Database service is owned and operated as a platform/database concern. The application receives:

- JDBC connect string
- schema ownership
- wallet or TLS material
- secrets through Vault/Kubernetes secret delivery

That keeps the demo honest. The app containers run on OKE. The database lives where the enterprise database is supposed to live.

## OCI Free Trial: "I Have A Bad Feeling About This"

We started in OCI Frankfurt with a free trial. The first plan used `VM.Standard.A1.Flex`, because ARM is attractive for demos and can fit into Always Free capacity.

Reality answered with:

```text
Out of host capacity
```

Twice.

First with a two-node ARM pool, then with a single tiny ARM node. The lesson was simple: free shape availability is not a design guarantee. It is more like finding parking near the cinema on opening night.

So we switched to paid trial-credit compute:

```hcl
node_shape      = "VM.Standard.E5.Flex"
node_count      = 2
node_ocpus      = 1
node_memory_gbs = 8
```

That gave us a practical x86 OKE worker pool for the demo.

## OKE Version And Image Adventures

The first OKE Kubernetes version in Terraform was stale. OCI rejected it and returned the supported versions. We updated the default to:

```hcl
kubernetes_version = "v1.34.2"
```

Then the node pool hit another issue: worker image selection.

The OCI node-pool options API returned multiple images, and the first x86 image was a GPU image. That was not compatible with the standard worker shape. Very "Raiders of the Lost Ark": the shiny artifact is right there, but if you pick the wrong one, things go badly.

We fixed this by resolving OKE node-pool images dynamically and filtering out GPU images for standard worker pools:

```hcl
locals {
  node_pool_sources = [
    for source in data.oci_containerengine_node_pool_option.selected.sources : source
    if !strcontains(source.source_name, "GPU")
  ]
  node_pool_source = local.node_pool_sources[0]
}
```

That kept the Terraform portable across regions without hardcoding image OCIDs.

## Authentication: Security Token Versus API Key

We first used OCI CLI session authentication:

```hcl
oci_auth = "SecurityToken"
```

That works for interactive use, until it does not. Terraform was polling a long OKE work request when the session expired. The result was a half-finished node pool and the kind of error message that makes you stare into the middle distance like Michael Corleone.

So we switched to API key auth:

```hcl
oci_auth = "ApiKey"
```

The API key setup is better for Terraform because it does not require browser refreshes during long operations. We generated a local signing key, uploaded the public key to the OCI user, and updated `~/.oci/config`.

One small footnote: OCI CLI accepts `--auth api_key`, while the Terraform provider expects `ApiKey`. Same movie, different subtitles.

## Kubernetes Networking: The Plot Twist

The OKE control plane came up. The worker nodes came up. Then the first node pool failed registration.

The initial security list allowed external admin access to the Kubernetes API on `6443`, but the workers also needed internal access to the API endpoint. Oracle's OKE networking requirements include more than just "let my laptop talk to Kubernetes".

We added the required API endpoint subnet ingress:

- VCN to TCP `6443`
- VCN to TCP `12250`
- VCN ICMP type `3`, code `4` for path discovery

After replacing the failed node pool, the workers registered successfully.

That was the "Casablanca" moment:

> Of all the security lists in all the regions in all the cloud, the nodes had to walk into this one.

## Current OCI Status

The current OCI platform is up:

- OKE control plane is active.
- E5 worker node pool is active.
- Both workers are active.
- OCIR repositories exist.
- OCI Streaming exists with the demo event streams.
- Vault and KMS exist.
- Terraform refresh works.
- Terraform plan reports no changes when run with serialized provider calls:

```bash
terraform -chdir=terraform/oci-target plan -parallelism=1
```

There is one remaining wrinkle: `kubectl` from the local workstation still gets TLS resets from the public OKE API endpoint. Temporarily opening the API endpoint more broadly did not fix it, and the workers are healthy, so this looks like a local/corporate network path issue to port `6443`.

The likely next step is to operate Kubernetes from one of:

- OCI Cloud Shell
- an OCI Bastion path
- a jump host or SSH tunnel inside the VCN

That is much less dramatic than "The Empire Strikes Back", but still a perfectly good sequel.

## What We Have Demonstrated

This setup shows more than "we can write three Spring Boot apps":

- We can model service boundaries in a real business domain.
- We can express REST and async contracts.
- We can run locally with Oracle and Kafka-compatible infrastructure.
- We can package for containers.
- We can define Helm deployment contracts.
- We can provision OCI target services with Terraform.
- We can handle OCI-specific realities: regions, compartments, OCIR, Streaming, Vault, OKE, node images, API key auth, and network rules.
- We can debug cloud setup when it behaves less like "Singin' in the Rain" and more like "Apocalypse Now".

## Lessons Learned

The short version:

- Do not rely on free ARM capacity being available.
- Use API key auth for Terraform, not expiring session tokens.
- Ask OCI for valid OKE versions and node images.
- Filter out GPU images when using standard CPU worker pools.
- OKE worker registration needs the full API endpoint rule set, including `12250` and ICMP path discovery.
- Keep Terraform state local files ignored.
- Keep local setup notes ignored too.
- When Terraform provider API signing behaves oddly, use low parallelism and verify with OCI CLI.

## Final Scene

ModaPrezzo now has a credible technical skeleton:

- microservices
- UI
- contracts
- BDD scenarios
- local runtime
- Helm deployment shape
- OCI infrastructure
- active OKE workers

The next chapter is deploying the application images into OKE and wiring runtime secrets for database and streaming access.

As classic movie wisdom goes: this is not the end. It is not even the beginning of the end. But it is, perhaps, the end of the scaffolding.
