CREATE TABLE f2c_user (
    email       VARCHAR(255) PRIMARY KEY,
    fname       VARCHAR(255) NOT NULL,
    lname       VARCHAR(255),
    password    VARCHAR(30) NOT NULL,
    user_type   INTEGER NOT NULL
);

CREATE TABLE contact_detail (
    user_id      VARCHAR(255) NOT NULL,
    address_id   SERIAL PRIMARY KEY,
    street1      VARCHAR(255) NOT NULL,
    street2      VARCHAR(255),
    city         VARCHAR(50) NOT NULL,
    state        VARCHAR(50) NOT NULL,
    country      VARCHAR(50) NOT NULL,
    zipcode      INTEGER NOT NULL,
    phone        VARCHAR(20) NOT NULL,
    is_default   INTEGER DEFAULT 0
);


CREATE TABLE customer (
    customer_id      VARCHAR(255) PRIMARY KEY,
    customer_name varchar(255) not null
	
);

CREATE TABLE farmer (
    farmer_id        VARCHAR(255) PRIMARY KEY,
    description      VARCHAR(255),
    average_rating   NUMERIC(2, 1) DEFAULT 0,
    rating_count     INTEGER DEFAULT 0,
	farmer_name   varchar(255)
);

CREATE TABLE category (
    category_id     SERIAL PRIMARY KEY,
    category_name   VARCHAR(255) NOT NULL
);

CREATE TABLE product (
    product_id         SERIAL PRIMARY KEY,
    name               VARCHAR(255) NOT NULL,
    farmer_id          VARCHAR(255) NOT NULL,
    price              NUMERIC(10, 2) NOT NULL,
    rating             NUMERIC(2, 1),
    review_count       INTEGER,
    category_id        INTEGER,
    description        VARCHAR(255),
    available_units(kg)    INTEGER,
    in_stock           INTEGER,
    carrier_phone       INTEGER
);

CREATE TABLE shopping_cart (
    customer_id     VARCHAR(255),
    date_added   DATE
);

CREATE TABLE product_shoppingcart (
    product_id   INTEGER,
    customer_id     VARCHAR(255),
    PRIMARY KEY (product_id, customer_id)
);
CREATE TABLE Payment (
    payment_id SERIAL PRIMARY KEY,
    order_id INTEGER ,
	customer_id VARCHAR(255) not null,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount  NUMERIC(10, 2) NOT NULL
);

CREATE TABLE f2c_order (
    order_id              SERIAL PRIMARY KEY,
    customer_id              VARCHAR(255) NOT NULL,
    total_price           NUMERIC(10, 2),
    order_date            DATE,
    shipping_price        NUMERIC(4, 2) DEFAULT 10,
    delivery_address_id   INTEGER,
    delivery_date         DATE,
    order_status          CHAR(1) NOT NULL,
    quantity              INTEGER NOT NULL
);

CREATE TABLE order_product (
    order_id     INTEGER,
    product_id   INTEGER,
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE review (
    review_id     SERIAL PRIMARY KEY,
    product_id    INTEGER NOT NULL,
    customer_id      VARCHAR(255) NOT NULL,
    review        VARCHAR(1000),
    rating        NUMERIC(2, 1),
    review_date   DATE
);


CREATE TABLE carrier (
    carrier_name    VARCHAR(255) NOT NULL,
	carrier_phone     INTEGER PRIMARY KEY,
    carrier_email   VARCHAR(255) NOT NULL
);

CREATE TABLE Machinery (
    machinery_id SERIAL PRIMARY KEY,
    farmer_id VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    available BOOLEAN  NOT NULL DEFAULT true
);
CREATE TABLE Borrower_details (
    Borrower_id varchar(255) NOT NULL, 
    machinery_id INT NOT NULL,
    owner_id  varchar(255) NOT NULL,
    borrowed_date TIMESTAMP,
    returned_date timestamp
);

ALTER TABLE contact_detail
    ADD CONSTRAINT contact_detail_user_id_fk FOREIGN KEY (user_id)
        REFERENCES f2c_user (email)
        ON DELETE CASCADE;

ALTER TABLE product
    ADD CONSTRAINT product_farmer_id_fk FOREIGN KEY (farmer_id)
        REFERENCES farmer (farmer_id)
        ON DELETE CASCADE;

ALTER TABLE product
    ADD CONSTRAINT product_category_id_fk FOREIGN KEY (category_id)
        REFERENCES category (category_id)
        ON DELETE CASCADE;

ALTER TABLE product
    ADD CONSTRAINT product_carrier_phone_fk FOREIGN KEY (carrier_phone)
        REFERENCES carrier (carrier_phone)
        ON DELETE CASCADE;

ALTER TABLE shopping_cart
    ADD CONSTRAINT shopping_cart_customer_id_fk FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id)
        ON DELETE CASCADE;

ALTER TABLE product_shoppingcart
    ADD CONSTRAINT product_sc_customer_id_fk FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id)
        ON DELETE CASCADE;

ALTER TABLE product_shoppingcart
    ADD CONSTRAINT product_sc_product_id_fk FOREIGN KEY (product_id)
        REFERENCES product (product_id)
        ON DELETE CASCADE;

ALTER TABLE f2c_order
    ADD CONSTRAINT order_customer_id_fk FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id)
        ON DELETE CASCADE;

ALTER TABLE f2c_order
    ADD CONSTRAINT order_delivery_address_id_fk FOREIGN KEY (delivery_address_id)
        REFERENCES contact_detail (address_id)
        ON DELETE CASCADE;

ALTER TABLE order_product
    ADD CONSTRAINT order_product_order_id_fk FOREIGN KEY (order_id)
        REFERENCES f2c_order (order_id)
        ON DELETE CASCADE;

ALTER TABLE order_product
    ADD CONSTRAINT order_product_product_id_fk FOREIGN KEY (product_id)
        REFERENCES product (product_id)
        ON DELETE CASCADE;

ALTER TABLE review
    ADD CONSTRAINT review_product_id_fk FOREIGN KEY (product_id)
        REFERENCES product (product_id)
        ON DELETE CASCADE;

ALTER TABLE review
    ADD CONSTRAINT review_customer_id_fk FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id)
        ON DELETE CASCADE;
		
ALTER TABLE payment
    ADD CONSTRAINT payment_order_id_fk FOREIGN KEY (order_id)
        REFERENCES f2c_order (order_id)
        ON DELETE CASCADE;
		
ALTER TABLE payment
    ADD CONSTRAINT payment_customer_id_fk FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id)
        ON DELETE CASCADE;

ALTER TABLE Machinery 
    ADD CONSTRAINT machinery_farmer_id_fk FOREIGN KEY (farmer_id)
        REFERENCES farmer (farmer_id)
        ON DELETE CASCADE;
	
ALTER TABLE Borrower_details 
    ADD CONSTRAINT Borrower_borrowed_id_fk FOREIGN KEY (borrower_id)
        REFERENCES farmer (farmer_id)
        ON DELETE CASCADE;
ALTER TABLE Borrower_details 
    ADD CONSTRAINT Borrower_owner_id_fk FOREIGN KEY (owner_id)
        REFERENCES farmer (farmer_id)
        ON DELETE CASCADE;
ALTER TABLE Borrower_details 
    ADD CONSTRAINT Borrower_machinery_id_fk FOREIGN KEY (machinery_id)
        REFERENCES machinery (machinery_id)
        ON DELETE CASCADE;