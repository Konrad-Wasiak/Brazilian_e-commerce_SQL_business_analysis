/* Queries creating tables for the main part of the dataset. */


/* PRODUCT_CATEGORY_NAME_TRANSLATION */
CREATE TABLE product_category_name_translation (
	product_category_name VARCHAR(100) PRIMARY KEY references product(category_name),
	product_category_name_english VARCHAR(100)
);

COPY product_category_name_translation FROM
	'"C:\Users\KW\Desktop\Programowanie\SQL\Projekt - Brazilian e-commerce\Dane\Część główna\product_category_name_translation.csv"'
		DELIMITER ','
			CSV HEADER;

/* SELLER */
CREATE TABLE seller (
	id CHAR(32) PRIMARY KEY,
	zip_code CHAR(5) references geolocation(zip_code),
	city VARCHAR(50),
	state CHAR(2)
);

COPY seller FROM
	'"C:\Users\KW\Desktop\Programowanie\SQL\Projekt - Brazilian e-commerce\Dane\Część główna\olist_sellers_dataset.csv"'
		DELIMITER ','
			CSV HEADER;

/* PRODUCT */
CREATE TABLE product (
	id CHAR(32) PRIMARY KEY,
	category_name VARCHAR(50) NOT NULL,
	/* Quantity of attached photos */
	photos_qty SMALLINT,
	weight_g INT,
	length_cm INT,
	height_cm INT,
	width_cm INT
);

COPY product FROM
	'"C:\Users\KW\Desktop\Programowanie\SQL\Projekt - Brazilian e-commerce\Dane\Część główna\olist_products_dataset.csv"'
		DELIMITER ','
			CSV HEADER;


/* GEOLOCATION */
CREATE TABLE geolocation (
	zip_code CHAR(5) PRIMARY KEY,
	lat SMALLINT,
	lng SMALLINT,
	city VARCHAR(50),
	state CHAR(2)
);

COPY geolocation FROM
	'"C:\Users\KW\Desktop\Programowanie\SQL\Projekt - Brazilian e-commerce\Dane\Część główna\olist_geolocation_dataset.csv"'
		DELIMITER ','
			CSV HEADER;

/* CUSTOMER */
CREATE TABLE customer (
	/* "Key to the orders dataset. Each order has a unique customer_id." - Olist */
	customer_order_id CHAR(32) references order(id),
	/* "Unique identifier of a customer" - Olist */
	id CHAR(32) PRIMARY KEY,
	zip_code CHAR(5) references geolocation(zip_code),
	city VARCHAR(50),
	state CHAR(2)
);

COPY customer FROM
	'"C:\Users\KW\Desktop\Programowanie\SQL\Projekt - Brazilian e-commerce\Dane\Część główna\olist_customers_dataset.csv"'
		DELIMITER ','
			CSV HEADER;
			
/* ORDER */
CREATE TABLE order (
	id CHAR(32) PRIMARY KEY,
	customer_id CHAR(32),
	/* delivered / shipped /canceled */
	status VARCHAR(8),
	purchase_timestamp TIMESTAMP,
	approved_at TIMESTAMP,
	delivered_carrier_date TIMESTAMP,
	delivered_customer_date TIMESTAMP,
	estimated_delivery_date TIMESTAMP,
	CONSTRAINT customer_order
		FOREIGN KEY(customer_id)
			REFERENCES customer(id)
);

COPY order FROM
	'"C:\Users\KW\Desktop\Programowanie\SQL\Projekt - Brazilian e-commerce\Dane\Część główna\olist_orders_dataset.csv"'
		DELIMITER ','
			CSV HEADER;


/* ORDER_REVIEW */
CREATE TABLE order_review (
	id CHAR(32) PRIMARY KEY,
	order_id CHAR(32) REFERENCES order(id),
	score SMALLINT,
	comment_title VARCHAR(100),
	comment_message VARCHAR(1000),
	creation_date TIMESTAMP,
	answer_timestamp TIMESTAMP,
	CONSTRAINT review_stars_con
		CHECK (score BETWEEN 0 AND 5)
);

COPY order_reviews FROM
	'"C:\Users\KW\Desktop\Programowanie\SQL\Projekt - Brazilian e-commerce\Dane\Część główna\olist_order_reviews_dataset.csv"'
		DELIMITER ','
			CSV HEADER;


/* ORDER_PAYMENTS */
CREATE TABLE order_payments (
	order_id PRIMARY KEY REFERENCES order(id),
	sequential SMALLINT NOT NULL,
	type VARCHAR(30),
	installments SMALLINT,
	value MONEY NOT NULL,
	CONSTRAINT min_value_con
		CHECK (value >= 0),
	CONSTRAINT min_installments_con
		CHECK (installments >= 1)
);

COPY order_payments FROM
	'"C:\Users\KW\Desktop\Programowanie\SQL\Projekt - Brazilian e-commerce\Dane\Część główna\olist_order_payments_dataset.csv"'
		DELIMITER ','
			CSV HEADER;


/* ORDER_ITEM */
CREATE TABLE order_item (
	order_id CHAR(32) NOT NULL REFERENCES order(id),
	items_number SMALLINT NOT NULL,
	product_id CHAR(32) NOT NULL REFERENCES product(id),
	seller_id CHAR(32) NOT NULL REFERENCES seller(id),
	shipping_limit_date TIMESTAMP NOT NULL,
	price MONEY NOT NULL,
	freight_value MONEY,
	CONSTRAINT order_item_pk
		PRIMARY KEY (order_id, product_id, seller_id)
);

COPY order_item FROM
	'"C:\Users\KW\Desktop\Programowanie\SQL\Projekt - Brazilian e-commerce\Dane\Część główna\olist_order_items_dataset.csv"'
		DELIMITER ','
			CSV HEADER;