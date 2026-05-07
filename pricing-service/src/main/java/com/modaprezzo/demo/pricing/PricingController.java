package com.modaprezzo.demo.pricing;

import java.time.Instant;
import java.util.Collection;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/prices")
public class PricingController {
    private static final String PRICE_CHANGED_TOPIC = "fashion.price.changed.v1";

    private final PriceRepository repository;
    private final KafkaTemplate<String, PriceChangedEvent> kafkaTemplate;

    public PricingController(PriceRepository repository, KafkaTemplate<String, PriceChangedEvent> kafkaTemplate) {
        this.repository = repository;
        this.kafkaTemplate = kafkaTemplate;
    }

    @GetMapping
    public Collection<MarketPrice> list() {
        return repository.findAll();
    }

    @GetMapping("/{productId}/{market}")
    public MarketPrice get(@PathVariable("productId") String productId, @PathVariable("market") String market) {
        return repository.findByProductIdAndMarket(productId, market)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Price not found"));
    }

    @PutMapping("/{productId}/{market}")
    @ResponseStatus(HttpStatus.ACCEPTED)
    public MarketPrice update(@PathVariable("productId") String productId, @PathVariable("market") String market,
                              @RequestBody MarketPrice request) {
        MarketPrice saved = repository.save(new MarketPrice(productId, market, request.currency(), request.amount(), PriceStatus.ACTIVE));
        kafkaTemplate.send(PRICE_CHANGED_TOPIC, productId, new PriceChangedEvent(
                UUID.randomUUID().toString(),
                productId,
                market,
                saved.currency(),
                saved.amount(),
                Instant.now()));
        return saved;
    }
}
