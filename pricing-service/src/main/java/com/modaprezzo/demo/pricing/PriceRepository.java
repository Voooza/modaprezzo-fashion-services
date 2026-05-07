package com.modaprezzo.demo.pricing;

import java.math.BigDecimal;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Optional;

import org.springframework.stereotype.Repository;

@Repository
public class PriceRepository {
    private final Map<String, MarketPrice> prices = new LinkedHashMap<>();

    public PriceRepository() {
        save(new MarketPrice("prd-1001", "DE", "EUR", new BigDecimal("49.99"), PriceStatus.ACTIVE));
    }

    public Collection<MarketPrice> findAll() {
        return prices.values();
    }

    public Optional<MarketPrice> findByProductIdAndMarket(String productId, String market) {
        return Optional.ofNullable(prices.get(key(productId, market)));
    }

    public MarketPrice save(MarketPrice price) {
        prices.put(key(price.productId(), price.market()), price);
        return price;
    }

    private String key(String productId, String market) {
        return productId + ":" + market;
    }
}
