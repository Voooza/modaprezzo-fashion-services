package com.modaprezzo.demo.pricing;

import java.math.BigDecimal;

import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
public class ProductPublishedListener {
    private final PriceRepository repository;

    public ProductPublishedListener(PriceRepository repository) {
        this.repository = repository;
    }

    @KafkaListener(topics = "fashion.product.published.v1")
    public void onProductPublished(ProductPublishedEvent event) {
        repository.findByProductIdAndMarket(event.productId(), "DE")
                .orElseGet(() -> repository.save(new MarketPrice(
                        event.productId(),
                        "DE",
                        "EUR",
                        new BigDecimal("39.99"),
                        PriceStatus.DRAFT)));
    }
}
