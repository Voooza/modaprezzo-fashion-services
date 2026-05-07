Feature: Product publication
  Merchandising teams need complete products to be published before they can be priced and sold.

  Scenario: Publish a product that is ready for selling
    Given a product "prd-1001" is ready for selling
    When the product manager publishes the product
    Then the catalog marks the product as published
    And a "fashion.product.published.v1" event is emitted

  Scenario: Reject publication of an incomplete product
    Given a product "prd-1002" is still in draft
    When the product manager publishes the product
    Then the publication request is rejected
    And no product publication event is emitted
