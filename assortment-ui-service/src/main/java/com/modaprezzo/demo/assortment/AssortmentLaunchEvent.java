package com.modaprezzo.demo.assortment;

import java.time.Instant;
import java.util.List;

public record AssortmentLaunchEvent(
        String eventId,
        String market,
        String collection,
        List<String> productIds,
        Instant occurredAt
) {
}
