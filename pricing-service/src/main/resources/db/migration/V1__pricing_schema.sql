CREATE TABLE market_prices (
    product_id VARCHAR2(64) NOT NULL,
    market VARCHAR2(8) NOT NULL,
    currency VARCHAR2(3) NOT NULL,
    amount NUMBER(12, 2) NOT NULL,
    status VARCHAR2(32) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT market_prices_pk PRIMARY KEY (product_id, market)
);

CREATE INDEX market_prices_market_idx ON market_prices (market);
