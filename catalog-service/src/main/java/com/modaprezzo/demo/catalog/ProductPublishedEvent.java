package com.modaprezzo.demo.catalog;

import java.time.Instant;

public record ProductPublishedEvent(
        String eventId,
        String productId,
        String styleNumber,
        String collection,
        Instant occurredAt
) {
}
