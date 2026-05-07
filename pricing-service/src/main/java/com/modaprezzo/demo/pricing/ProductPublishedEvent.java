package com.modaprezzo.demo.pricing;

import java.time.Instant;

public record ProductPublishedEvent(
        String eventId,
        String productId,
        String styleNumber,
        String collection,
        Instant occurredAt
) {
}
