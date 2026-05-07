package com.modaprezzo.demo.pricing;

import java.math.BigDecimal;
import java.time.Instant;

public record PriceChangedEvent(
        String eventId,
        String productId,
        String market,
        String currency,
        BigDecimal amount,
        Instant occurredAt
) {
}
