# Catalog Service

Owns fashion product master data for sellable items: style, color, size range, collection, market readiness, and publication status.

## Interfaces

- REST API: `spec/openapi.yaml`
- Async events: `spec/asyncapi.yaml`
- BDD scenarios: `bdd/catalog_publication.feature`

## Responsibilities

- Maintain product and SKU records.
- Validate that a product has merchandising attributes before publication.
- Publish `fashion.product.published.v1` when a product becomes sellable.

## Integrations

- `pricing-service` consumes product publication events and reads product details through REST.
- `assortment-ui-service` reads product lists and details through REST.
