Feature: Market pricing
  Merchandisers need active prices before a fashion product can be launched in a market.

  Scenario: Create a default price draft for a newly published product
    Given the catalog publishes product "prd-1001"
    When the pricing service receives the product publication event
    Then a draft "DE" market price is created

  Scenario: Activate a market price
    Given a draft "DE" market price exists for product "prd-1001"
    When the pricing manager sets the price to "49.99" "EUR"
    Then the "DE" market price becomes active
    And a "fashion.price.changed.v1" event is emitted
