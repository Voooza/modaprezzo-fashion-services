CREATE TABLE products (
    id VARCHAR2(64) PRIMARY KEY,
    style_number VARCHAR2(64) NOT NULL,
    name VARCHAR2(255) NOT NULL,
    collection_code VARCHAR2(32) NOT NULL,
    color VARCHAR2(64) NOT NULL,
    status VARCHAR2(32) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL
);

CREATE TABLE product_sizes (
    product_id VARCHAR2(64) NOT NULL,
    display_order NUMBER(4) NOT NULL,
    size_code VARCHAR2(16) NOT NULL,
    CONSTRAINT product_sizes_pk PRIMARY KEY (product_id, display_order),
    CONSTRAINT product_sizes_product_fk FOREIGN KEY (product_id)
        REFERENCES products (id) ON DELETE CASCADE
);

CREATE INDEX product_sizes_product_idx ON product_sizes (product_id);
