package com.modaprezzo.demo.assortment;

import java.time.Instant;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;

@Component
public class AssortmentGateway {
    private static final String ASSORTMENT_LAUNCHED_TOPIC = "fashion.assortment.launched.v1";

    private final WebClient catalogClient;
    private final WebClient pricingClient;
    private final KafkaTemplate<String, AssortmentLaunchEvent> kafkaTemplate;

    public AssortmentGateway(@Value("${catalog.base-url}") String catalogBaseUrl,
                             @Value("${pricing.base-url}") String pricingBaseUrl,
                             KafkaTemplate<String, AssortmentLaunchEvent> kafkaTemplate) {
        this.catalogClient = WebClient.builder().baseUrl(catalogBaseUrl).build();
        this.pricingClient = WebClient.builder().baseUrl(pricingBaseUrl).build();
        this.kafkaTemplate = kafkaTemplate;
    }

    public List<ProductSummary> products() {
        ProductSummary[] products = catalogClient.get()
                .uri("/api/products")
                .retrieve()
                .bodyToMono(ProductSummary[].class)
                .blockOptional()
                .orElse(new ProductSummary[0]);
        return Arrays.asList(products);
    }

    public MarketPrice priceFor(String productId, String market) {
        return pricingClient.get()
                .uri("/api/prices/{productId}/{market}", productId, market)
                .retrieve()
                .bodyToMono(MarketPrice.class)
                .onErrorComplete()
                .block();
    }

    public void launch(String market, String collection, List<String> productIds) {
        kafkaTemplate.send(ASSORTMENT_LAUNCHED_TOPIC, market + ":" + collection, new AssortmentLaunchEvent(
                UUID.randomUUID().toString(),
                market,
                collection,
                productIds,
                Instant.now()));
    }
}
