package com.modaprezzo.demo.catalog;

import java.util.List;

public record Product(
        String id,
        String styleNumber,
        String name,
        String collection,
        String color,
        List<String> sizes,
        ProductStatus status
) {
}
