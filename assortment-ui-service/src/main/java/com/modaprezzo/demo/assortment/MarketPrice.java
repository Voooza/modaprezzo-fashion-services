package com.modaprezzo.demo.assortment;

import java.math.BigDecimal;

public record MarketPrice(
        String productId,
        String market,
        String currency,
        BigDecimal amount,
        String status
) {
}
