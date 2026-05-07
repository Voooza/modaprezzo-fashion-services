package com.modaprezzo.demo.assortment;

import java.util.List;

import com.vaadin.flow.component.button.Button;
import com.vaadin.flow.component.grid.Grid;
import com.vaadin.flow.component.html.H1;
import com.vaadin.flow.component.notification.Notification;
import com.vaadin.flow.component.orderedlayout.VerticalLayout;
import com.vaadin.flow.router.Route;

@Route("")
public class AssortmentView extends VerticalLayout {
    private final AssortmentGateway gateway;
    private final Grid<ProductSummary> grid = new Grid<>(ProductSummary.class, false);

    public AssortmentView(AssortmentGateway gateway) {
        this.gateway = gateway;

        setSizeFull();
        add(new H1("Fashion Assortment Workbench"));

        grid.addColumn(ProductSummary::styleNumber).setHeader("Style");
        grid.addColumn(ProductSummary::name).setHeader("Product");
        grid.addColumn(ProductSummary::collection).setHeader("Collection");
        grid.addColumn(ProductSummary::color).setHeader("Color");
        grid.addColumn(ProductSummary::status).setHeader("Catalog status");
        grid.addColumn(product -> {
            MarketPrice price = gateway.priceFor(product.id(), "DE");
            return price == null ? "Missing" : price.amount() + " " + price.currency() + " (" + price.status() + ")";
        }).setHeader("DE price");
        grid.setItems(gateway.products());

        Button launchButton = new Button("Launch DE SS26", event -> launchSelectedAssortment());
        add(grid, launchButton);
    }

    private void launchSelectedAssortment() {
        List<String> productIds = gateway.products().stream()
                .filter(product -> "SS26".equals(product.collection()))
                .map(ProductSummary::id)
                .toList();
        gateway.launch("DE", "SS26", productIds);
        Notification.show("DE SS26 assortment launch event published");
    }
}
