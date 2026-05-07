# Pricing Service

Owns market prices, promotion eligibility, and simple margin guardrails for fashion products.

## Interfaces

- REST API: `spec/openapi.yaml`
- Async events: `spec/asyncapi.yaml`
- BDD scenarios: `bdd/market_pricing.feature`

## Responsibilities

- Provide current prices by product and sales market.
- Create price drafts when a product is published.
- Publish `fashion.price.changed.v1` when a market price changes.

## Integrations

- Reads product details from `catalog-service` through REST.
- Consumes `fashion.product.published.v1` from `catalog-service`.
- Provides prices to `assortment-ui-service` through REST.
