package com.modaprezzo.demo.catalog;

import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Optional;

import org.springframework.stereotype.Repository;

@Repository
public class ProductRepository {
    private final Map<String, Product> products = new LinkedHashMap<>();

    public ProductRepository() {
        save(new Product("prd-1001", "MP-SS26-DR-001", "Linen summer dress", "SS26", "coral", 
                java.util.List.of("34", "36", "38", "40", "42"), ProductStatus.READY_FOR_SELLING));
        save(new Product("prd-1002", "MP-SS26-JK-014", "Lightweight utility jacket", "SS26", "sage",
                java.util.List.of("XS", "S", "M", "L", "XL"), ProductStatus.DRAFT));
    }

    public Collection<Product> findAll() {
        return products.values();
    }

    public Optional<Product> findById(String id) {
        return Optional.ofNullable(products.get(id));
    }

    public Product save(Product product) {
        products.put(product.id(), product);
        return product;
    }
}
