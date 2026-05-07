package com.modaprezzo.demo.catalog;

import java.time.Instant;
import java.util.Collection;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/products")
public class ProductController {
    private static final String PRODUCT_PUBLISHED_TOPIC = "fashion.product.published.v1";

    private final ProductRepository repository;
    private final KafkaTemplate<String, ProductPublishedEvent> kafkaTemplate;

    public ProductController(ProductRepository repository, KafkaTemplate<String, ProductPublishedEvent> kafkaTemplate) {
        this.repository = repository;
        this.kafkaTemplate = kafkaTemplate;
    }

    @GetMapping
    public Collection<Product> list() {
        return repository.findAll();
    }

    @GetMapping("/{id}")
    public Product get(@PathVariable("id") String id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Product not found"));
    }

    @PostMapping("/{id}/publish")
    @ResponseStatus(HttpStatus.ACCEPTED)
    public Product publish(@PathVariable("id") String id) {
        Product product = get(id);
        if (product.status() == ProductStatus.DRAFT) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Product is not ready for selling");
        }

        Product published = new Product(product.id(), product.styleNumber(), product.name(), product.collection(),
                product.color(), product.sizes(), ProductStatus.PUBLISHED);
        repository.save(published);

        kafkaTemplate.send(PRODUCT_PUBLISHED_TOPIC, published.id(), new ProductPublishedEvent(
                UUID.randomUUID().toString(),
                published.id(),
                published.styleNumber(),
                published.collection(),
                Instant.now()));

        return published;
    }
}
