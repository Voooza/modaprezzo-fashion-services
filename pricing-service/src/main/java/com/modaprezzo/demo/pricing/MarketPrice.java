package com.modaprezzo.demo.pricing;

import java.math.BigDecimal;

public record MarketPrice(
        String productId,
        String market,
        String currency,
        BigDecimal amount,
        PriceStatus status
) {
}
