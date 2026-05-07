package com.modaprezzo.demo.pricing;

import java.util.Collection;
import java.util.Optional;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

@Repository
public class PriceRepository {
    private static final RowMapper<MarketPrice> PRICE_ROW_MAPPER = (rs, rowNum) -> new MarketPrice(
            rs.getString("product_id"),
            rs.getString("market"),
            rs.getString("currency"),
            rs.getBigDecimal("amount"),
            PriceStatus.valueOf(rs.getString("status")));

    private final JdbcTemplate jdbcTemplate;

    public PriceRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public Collection<MarketPrice> findAll() {
        return jdbcTemplate.query("""
                SELECT product_id, market, currency, amount, status
                FROM market_prices
                ORDER BY product_id, market
                """, PRICE_ROW_MAPPER);
    }

    public Optional<MarketPrice> findByProductIdAndMarket(String productId, String market) {
        return jdbcTemplate.query("""
                SELECT product_id, market, currency, amount, status
                FROM market_prices
                WHERE product_id = ? AND market = ?
                """, PRICE_ROW_MAPPER, productId, market).stream().findFirst();
    }

    public MarketPrice save(MarketPrice price) {
        jdbcTemplate.update("""
                MERGE INTO market_prices target
                USING (
                    SELECT ? product_id, ? market, ? currency, ? amount, ? status
                    FROM dual
                ) source
                ON (target.product_id = source.product_id AND target.market = source.market)
                WHEN MATCHED THEN UPDATE SET
                    target.currency = source.currency,
                    target.amount = source.amount,
                    target.status = source.status,
                    target.updated_at = SYSTIMESTAMP
                WHEN NOT MATCHED THEN INSERT (
                    product_id, market, currency, amount, status, updated_at
                ) VALUES (
                    source.product_id, source.market, source.currency, source.amount,
                    source.status, SYSTIMESTAMP
                )
                """,
                price.productId(), price.market(), price.currency(), price.amount(), price.status().name());
        return price;
    }
}
