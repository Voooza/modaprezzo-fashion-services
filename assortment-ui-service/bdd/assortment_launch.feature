Feature: Market assortment launch
  Merchandisers need one place to check product and price readiness before launching a fashion assortment.

  Scenario: Show products and prices for a market
    Given published catalog products exist for collection "SS26"
    And active "DE" market prices exist for those products
    When the merchandiser opens the assortment workbench
    Then the UI shows each product with its catalog status
    And the UI shows the current "DE" price status

  Scenario: Launch a market assortment
    Given the merchandiser has reviewed collection "SS26" for market "DE"
    When the merchandiser launches the assortment
    Then a "fashion.assortment.launched.v1" event is emitted
    And the event contains the market, collection, and launched product ids
