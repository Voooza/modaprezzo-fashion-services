package com.modaprezzo.demo.catalog;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
public class ProductRepository {
    private static final RowMapper<Product> PRODUCT_ROW_MAPPER = (rs, rowNum) -> new Product(
            rs.getString("id"),
            rs.getString("style_number"),
            rs.getString("name"),
            rs.getString("collection_code"),
            rs.getString("color"),
            List.of(),
            ProductStatus.valueOf(rs.getString("status")));

    private final JdbcTemplate jdbcTemplate;

    public ProductRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public Collection<Product> findAll() {
        return jdbcTemplate.query("""
                SELECT id, style_number, name, collection_code, color, status
                FROM products
                ORDER BY id
                """, PRODUCT_ROW_MAPPER).stream()
                .map(this::withSizes)
                .toList();
    }

    public Optional<Product> findById(String id) {
        return jdbcTemplate.query("""
                SELECT id, style_number, name, collection_code, color, status
                FROM products
                WHERE id = ?
                """, PRODUCT_ROW_MAPPER, id).stream()
                .findFirst()
                .map(this::withSizes);
    }

    @Transactional
    public Product save(Product product) {
        jdbcTemplate.update("""
                MERGE INTO products target
                USING (
                    SELECT ? id, ? style_number, ? name, ? collection_code, ? color, ? status
                    FROM dual
                ) source
                ON (target.id = source.id)
                WHEN MATCHED THEN UPDATE SET
                    target.style_number = source.style_number,
                    target.name = source.name,
                    target.collection_code = source.collection_code,
                    target.color = source.color,
                    target.status = source.status,
                    target.updated_at = SYSTIMESTAMP
                WHEN NOT MATCHED THEN INSERT (
                    id, style_number, name, collection_code, color, status, updated_at
                ) VALUES (
                    source.id, source.style_number, source.name, source.collection_code,
                    source.color, source.status, SYSTIMESTAMP
                )
                """,
                product.id(), product.styleNumber(), product.name(), product.collection(), product.color(),
                product.status().name());

        jdbcTemplate.update("DELETE FROM product_sizes WHERE product_id = ?", product.id());
        for (int i = 0; i < product.sizes().size(); i++) {
            jdbcTemplate.update("""
                    INSERT INTO product_sizes (product_id, display_order, size_code)
                    VALUES (?, ?, ?)
                    """, product.id(), i + 1, product.sizes().get(i));
        }
        return product;
    }

    private Product withSizes(Product product) {
        List<String> sizes = jdbcTemplate.query("""
                SELECT size_code
                FROM product_sizes
                WHERE product_id = ?
                ORDER BY display_order
                """, (rs, rowNum) -> rs.getString("size_code"), product.id());

        return new Product(product.id(), product.styleNumber(), product.name(), product.collection(),
                product.color(), sizes, product.status());
    }
}
