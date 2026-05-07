# Assortment UI Service

Vaadin-based workbench for merchandisers to review sellable products, inspect market prices, and launch a market assortment.

## Interfaces

- REST/API notes: `spec/openapi.yaml`
- Async events: `spec/asyncapi.yaml`
- BDD scenarios: `bdd/assortment_launch.feature`

## Responsibilities

- Display catalog products and pricing status in one UI.
- Call `catalog-service` and `pricing-service` through REST.
- Publish `fashion.assortment.launched.v1` when a market launch is confirmed.

## Integrations

- REST client to `catalog-service` at `CATALOG_BASE_URL`.
- REST client to `pricing-service` at `PRICING_BASE_URL`.
- Kafka producer for assortment launch events.
