/* Queries creating tables for the main part of the dataset. */

/* GEOLOCATION */
/* 
There's a problem with the following table - although zip_code_prefix was supposed to be a primary key, there are duplicates with different
lat and lng combinations, which aren't present at other tables, so joining in that configuration could be problematic.
However, for BI purposes that mostly operates on aggregated data, we do not need exact coordinates - zip code prefixes are precise enough.
To deal with the problem, I am creating the table in a way that matches the csv file and then creating a new table, based on the first one,
with  zip_code_prefix and city serving as a primary key. That will allow us to join tables without any complications.
*/
BEGIN;

CREATE TABLE IF NOT EXISTS geolocation_original (
	zip_code_prefix CHAR(5) NOT NULL,
	lat SMALLINT UNIQUE NOT NULL,
	lng SMALLINT UNIQUE NOT NULL,
	city VARCHAR(50),
	state CHAR(2),
	
	CONSTRAINT geolocation_pk
		PRIMARY KEY (lat, lng)
);

COPY geolocation_original FROM
	'C:\Users\KW\Desktop\Programowanie\SQL\Project - Brazilian e-commerce\Data\Main e-commerce data\olist_geolocation_dataset.csv'
		DELIMITER ','
			CSV HEADER;

CREATE TABLE IF NOT EXISTS geolocation AS
	SELECT DISTINCT zip_code_prefix, city, state
		FROM geolocation_original;
		
ALTER TABLE geolocation
	ADD CONSTRAINT PRIMARY KEY (zip_code_prefix, city);
	
DROP TABLE geolocation_old;


/* PRODUCT_CATEGORY_NAME_TRANSLATION */
CREATE TABLE IF NOT EXISTS product_category_name_translation (
	product_category_name VARCHAR(100) PRIMARY KEY references product(category_name),
	product_category_name_english VARCHAR(100) NOT NULL
);

COPY product_category_name_translation FROM
	'C:\Users\KW\Desktop\Programowanie\SQL\Project - Brazilian e-commerce\Data\Main e-commerce data\product_category_name_translation.csv'
		DELIMITER ','
			CSV HEADER;


/* SELLER */
CREATE TABLE IF NOT EXISTS seller (
	id CHAR(32) PRIMARY KEY,
	zip_code CHAR(5) references geolocation(zip_code),
	city VARCHAR(50),
	state CHAR(2)
);

COPY seller FROM
	'C:\Users\KW\Desktop\Programowanie\SQL\Project - Brazilian e-commerce\Data\Main e-commerce data\olist_sellers_dataset.csv'
		DELIMITER ','
			CSV HEADER;


/* PRODUCT */
CREATE TABLE IF NOT EXISTS product (
	id CHAR(32) PRIMARY KEY,
	category_name VARCHAR(50) NOT NULL,
	name_length SMALLINT,
	description_length SMALLINT,
	photos_qty SMALLINT,
	weight_g INT,
	length_cm INT,
	height_cm INT,
	width_cm INT,
	
	CONSTRAINT min_values
		CHECK (photos_qty >= 0 AND weight_g >= 0 AND length_cm >= 0 AND height_cm >= 0 AND width_cm >= 0 AND name_length >= 0 AND description_length >= 0)
);

COPY product FROM
	'C:\Users\KW\Desktop\Programowanie\SQL\Project - Brazilian e-commerce\Data\Main e-commerce data\olist_products_dataset.csv'
		DELIMITER ','
			CSV HEADER;


/* CUSTOMER */
CREATE TABLE IF NOT EXISTS customer (
	customer_order_id CHAR(32) references order(id),
	id CHAR(32) PRIMARY KEY,
	zip_code CHAR(5) references geolocation(zip_code),
	city VARCHAR(50),
	state CHAR(2)
);

COPY customer FROM
	'C:\Users\KW\Desktop\Programowanie\SQL\Project - Brazilian e-commerce\Data\Main e-commerce data\olist_customer_dataset.csv'
		DELIMITER ','
			CSV HEADER;
			
			
/* ORDER */
CREATE TABLE IF NOT EXISTS order (
	id CHAR(32) PRIMARY KEY,
	customer_id CHAR(32) NOT NULL,
	status VARCHAR(8) NOT NULL,
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
	'C:\Users\KW\Desktop\Programowanie\SQL\Project - Brazilian e-commerce\Data\Main e-commerce data\olist_orders_dataset.csv'
		DELIMITER ','
			CSV HEADER;


/* ORDER_REVIEW */
CREATE TABLE IF NOT EXISTS order_review (
	id CHAR(32) PRIMARY KEY,
	order_id CHAR(32) NOT NULL REFERENCES order(id),
	score SMALLINT NOT NULL,
	comment_title VARCHAR(100),
	comment_message VARCHAR(1000),
	creation_date TIMESTAMP,
	answer_timestamp TIMESTAMP,
	
	CONSTRAINT review_stars_con
		CHECK (score BETWEEN 0 AND 5)
);

COPY order_review FROM
	'C:\Users\KW\Desktop\Programowanie\SQL\Project - Brazilian e-commerce\Data\Main e-commerce data\olist_order_reviews_dataset.csv'
		DELIMITER ','
			CSV HEADER;


/* ORDER_PAYMENT */
CREATE TABLE IF NOT EXISTS order_payment (
	order_id PRIMARY KEY REFERENCES order(id),
	sequential SMALLINT NOT NULL,
	type VARCHAR(30),
	installments SMALLINT,
	value MONEY NOT NULL,
	
	CONSTRAINT min_values
		CHECK (value >= 0 AND sequential > 0 AND installments > 0)
);

COPY order_payment FROM
	'C:\Users\KW\Desktop\Programowanie\SQL\Project - Brazilian e-commerce\Data\Main e-commerce data\olist_order_payments_dataset.csv'
		DELIMITER ','
			CSV HEADER;


/* ORDER_ITEM */
CREATE TABLE IF NOT EXISTS order_item (
	order_id CHAR(32) NOT NULL REFERENCES order(id),
	items_number SMALLINT NOT NULL,
	product_id CHAR(32) NOT NULL REFERENCES product(id),
	seller_id CHAR(32) NOT NULL REFERENCES seller(id),
	shipping_limit_date TIMESTAMP NOT NULL,
	price MONEY NOT NULL,
	freight_value MONEY,
	
	CONSTRAINT order_item_pk
		PRIMARY KEY (order_id, product_id, seller_id),
	CONSTRAINT minimal_values
		CHECK (items_number > 0 AND price >= 0 AND freight_value >= 0),
	CONSTRAINT freight_value_dependency
		CHECK (freight_value <= price)
);

COPY order_item FROM
	'C:\Users\KW\Desktop\Programowanie\SQL\Project - Brazilian e-commerce\Data\Main e-commerce data\olist_order_items_dataset.csv'
		DELIMITER ','
			CSV HEADER;
			
COMMIT;		
			