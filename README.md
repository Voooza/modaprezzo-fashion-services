# Fashion Commerce Microservice Demonstrator

This directory contains a lightweight technical demonstrator for a fashion-selling domain aligned with the D:Suite target stack:

- Java 21 and Spring Boot services
- Vaadin UI for product and assortment workflows
- REST APIs for synchronous service integration
- Kafka-compatible async messaging for product, price, and assortment events
- Oracle JDBC persistence with Flyway migrations for the stateful services
- Docker and Kubernetes-ready service boundaries
- Terraform notes for OCI/Kubernetes deployment

## Services

| Service | Responsibility | REST integrations | Async messaging |
| --- | --- | --- | --- |
| `catalog-service` | Owns fashion products, SKUs, seasonal collections, and publication status. | Provides product and SKU APIs consumed by pricing and UI. | Publishes `ProductPublished` events. |
| `pricing-service` | Owns country-specific prices, promotion eligibility, and margin guardrails. | Reads product data from catalog and exposes price lookup APIs. | Consumes `ProductPublished`; publishes `PriceChanged`. |
| `assortment-ui-service` | Vaadin workbench for merchandisers to review products, prices, and launch market assortments. | Reads catalog and pricing APIs. | Publishes `AssortmentLaunched` events. |

## Local Shape

The services are intentionally scaffold-level. They include source layout, Dockerfiles, Maven descriptors, API/event specs, BDD scenarios, and enough code structure to communicate design intent without pretending to be production-complete.

```text
dev/
  catalog-service/
  pricing-service/
  assortment-ui-service/
  deploy/
  terraform/
  local/
  docker-compose.yml
```

## Build

If Maven is configured with a global corporate mirror that is not available from this machine, use the included clean settings file:

```bash
cd dev/catalog-service && mvn -gs ../maven-settings.xml -s ../maven-settings.xml test
cd dev/pricing-service && mvn -gs ../maven-settings.xml -s ../maven-settings.xml test
cd dev/assortment-ui-service && mvn -gs ../maven-settings.xml -s ../maven-settings.xml test
```

Package the jars before building local containers:

```bash
cd dev/catalog-service && mvn -gs ../maven-settings.xml -s ../maven-settings.xml package
cd ../pricing-service && mvn -gs ../maven-settings.xml -s ../maven-settings.xml package
cd ../assortment-ui-service && mvn -gs ../maven-settings.xml -s ../maven-settings.xml package
```

## Local Runtime

`docker-compose.yml` starts the closest practical workstation runtime:

- Oracle Database Free with separate `catalog_app` and `pricing_app` schemas.
- Apache Kafka as the local stand-in for OCI Streaming's Kafka-compatible endpoint.
- The three Spring Boot service containers.

The database passwords in this repository are local-only demo credentials. Real OCI deployments should use OCI Vault or the customer-approved secret-management pattern.

```bash
podman compose up --build -d
```

## Kubernetes And OCI Shape

The Helm chart in `deploy/helm/modaprezzo` is the shared deployment contract for local Kubernetes and OCI Kubernetes Engine.

- `values-local.yaml` points to local Oracle/Kafka endpoints.
- `values-oci.yaml` contains placeholders for OCIR images, Exadata connection service, OCI Streaming Kafka endpoint, ingress, and externally managed secrets.

In OCI, the services run on OKE and connect to Oracle Database on Exadata through JDBC. The application containers do not run on Exadata; Exadata provides the managed Oracle Database runtime.

## Integration Flow

1. A product manager publishes a product in `catalog-service`.
2. `catalog-service` emits `fashion.product.published.v1`.
3. `pricing-service` consumes the event and prepares a default market price draft.
4. `assortment-ui-service` retrieves products and prices via REST for merchandiser review.
5. When a market assortment is launched, the UI emits `fashion.assortment.launched.v1`.

## Suggested Next Steps

- Add Testcontainers-based integration tests for Kafka and REST contracts.
- Add GitLab CI jobs for build, test, container scan, and deployment manifest validation.
- Map Terraform modules to the customer-provided OCI tenancy, OKE cluster, registry, networking, and observability standards.
