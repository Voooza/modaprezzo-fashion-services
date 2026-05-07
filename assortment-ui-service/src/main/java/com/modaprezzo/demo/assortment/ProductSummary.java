package com.modaprezzo.demo.assortment;

import java.util.List;

public record ProductSummary(
        String id,
        String styleNumber,
        String name,
        String collection,
        String color,
        List<String> sizes,
        String status
) {
}
