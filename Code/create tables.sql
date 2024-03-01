/*
Queries creating initial tables for the main part of the dataset.
Some constraints might be altered after further examination of the created tables.
*/

/* 
The list of problems that appeared at this step and are going to be taken care of during the next step -
- investigating the quality of the data:

1. Geolocation: it appears that there are duplicate values for the zip_code_prefix and city combination only.
For now, I'm setting the primary key as zip_code_prefix, city, and state.

2. Geolocation: while trying to add a foreign key referencing the geolocation table to the other tables,
it turned out that the table doesn't contain all the necessary locations.
For now, I'm going to skip this foreign key constraint.

3. Product_category_name_translation: there's no translation for every product category in the product table.
Temporarily skipping the foreign key constraint.

4. Customer: duplicate customer_unique_id values. Skipping the primary key constraint for now.

5. Order_review: same issue with review_id as above with the customer table.

6. Order_payment: same issue with order_id as above with order_review and customer.
*/
SELECT * FROM product
	LIMIT 100;
BEGIN;

/* GEOLOCATION */
/* 
Althugh zip_code_prefix was supposed to be a primary key in the geolocation table,
there are duplicates with different lat and lng combinations, which aren't present at other tables,
so joining in that configuration could be problematic. 
However, for BI purposes that mostly concern aggregated data,
we do not need exact coordinates - zip code prefixes are precise enough.
To deal with the problem, I am creating the table in a way that matches the csv file and then creating a new table, 
based on the first one, with  zip_code_prefix and city serving as a primary key. 
That will allow us to join tables without any complications.
*/
CREATE TABLE IF NOT EXISTS geolocation_original (
	geolocation_zip_code_prefix CHAR(5) NOT NULL,
	geolocation_lat FLOAT NOT NULL,
	geolocation_lng FLOAT NOT NULL,
	geolocation_city VARCHAR(50) NOT NULL,
	geolocation_state CHAR(2) NOT NULL
);

COPY geolocation_original FROM
	'C:\Users\KW\Desktop\Programowanie\SQL\Project - Brazilian e-commerce\Data\Main e-commerce data\Pre-processed data\olist_geolocation_dataset_cleaned.csv'
		DELIMITER ','
			CSV HEADER;

CREATE TABLE IF NOT EXISTS geolocation AS
	SELECT DISTINCT geolocation_zip_code_prefix, geolocation_city, geolocation_state
		FROM geolocation_original;

ALTER TABLE geolocation
	ADD PRIMARY KEY (geolocation_zip_code_prefix, geolocation_city, geolocation_state);
	
DROP TABLE geolocation_original;


/* SELLER */
CREATE TABLE IF NOT EXISTS seller (
	seller_id CHAR(32) PRIMARY KEY,
	seller_zip_code_prefix CHAR(5),
	seller_city VARCHAR(50),
	seller_state CHAR(2)
	
	/*,CONSTRAINT seller_fk
		FOREIGN KEY (seller_zip_code_prefix, seller_city, seller_state)
			REFERENCES geolocation(geolocation_zip_code_prefix, geolocation_city, geolocation_state)*/
);

COPY seller FROM
	'C:\Users\KW\Desktop\Programowanie\SQL\Project - Brazilian e-commerce\Data\Main e-commerce data\Pre-processed data\olist_sellers_dataset_cleaned.csv'
		DELIMITER ','
			CSV HEADER;


/* PRODUCT_CATEGORY_NAME_TRANSLATION */
CREATE TABLE IF NOT EXISTS product_category_name_translation (
	product_category_name VARCHAR(100) PRIMARY KEY,
	product_category_name_english VARCHAR(100) NOT NULL
);

COPY product_category_name_translation FROM
	'C:\Users\KW\Desktop\Programowanie\SQL\Project - Brazilian e-commerce\Data\Main e-commerce data\Pre-processed data\product_category_name_translation_cleaned.csv'
		DELIMITER ','
			CSV HEADER;


/* PRODUCT */
CREATE TABLE IF NOT EXISTS product (
	product_id CHAR(32) PRIMARY KEY,
	product_category_name VARCHAR(50) /*REFERENCES product_category_name_translation(product_category_name)*/,
	product_name_length FLOAT,
	product_description_length FLOAT,
	product_photos_qty FLOAT,
	product_weight_g FLOAT,
	product_length_cm FLOAT,
	product_height_cm FLOAT,
	product_width_cm FLOAT,
	
	CONSTRAINT min_values
		CHECK (product_photos_qty >= 0 AND product_weight_g >= 0 AND product_length_cm >= 0 AND product_height_cm >= 0 AND product_width_cm >= 0 AND product_name_length >= 0 AND product_description_length >= 0)
);

COPY product FROM
	'C:\Users\KW\Desktop\Programowanie\SQL\Project - Brazilian e-commerce\Data\Main e-commerce data\Pre-processed data\olist_products_dataset_cleaned.csv'
		DELIMITER ','
			CSV HEADER;
			
			
/* ORDER */
CREATE TABLE IF NOT EXISTS "order" (
	order_id CHAR(32) PRIMARY KEY,
	customer_id CHAR(32) NOT NULL UNIQUE,
	order_status VARCHAR(13) NOT NULL,
	order_purchase_timestamp TIMESTAMP,
	order_approved_at TIMESTAMP,
	order_delivered_carrier_date TIMESTAMP,
	order_delivered_customer_date TIMESTAMP,
	order_estimated_delivery_date TIMESTAMP
);

COPY "order" FROM
	'C:\Users\KW\Desktop\Programowanie\SQL\Project - Brazilian e-commerce\Data\Main e-commerce data\Pre-processed data\olist_orders_dataset_cleaned.csv'
		DELIMITER ','
			CSV HEADER;
			
			
/* CUSTOMER */
CREATE TABLE IF NOT EXISTS customer (
	customer_id CHAR(32),
	customer_unique_id CHAR(32) /*PRIMARY KEY*/,
	customer_zip_code_prefix CHAR(5),
	customer_city VARCHAR(50),
	customer_state CHAR(2),
	
	/*CONSTRAINT customer_geo_fk
		FOREIGN KEY (customer_zip_code_prefix, customer_city, customer_state)
			REFERENCES geolocation(customer_zip_code_prefix, customer_city, customer_state),*/
	CONSTRAINT customer_order_fk
		/* 
		While it might be controversial to make order a parent table to customer,
		it's more relevant for the character of the customer_order_id column -
		- each customer_order_id is unique to an order and one customer can be related to many customer_order ids.
		*/
		FOREIGN KEY (customer_id)
			REFERENCES "order"(customer_id)
);

COPY customer FROM
	'C:\Users\KW\Desktop\Programowanie\SQL\Project - Brazilian e-commerce\Data\Main e-commerce data\Pre-processed data\olist_customers_dataset_cleaned.csv'
		DELIMITER ','
			CSV HEADER;


/* ORDER_REVIEW */
CREATE TABLE IF NOT EXISTS order_review (
	review_id CHAR(32) /*PRIMARY KEY*/,
	order_id CHAR(32) NOT NULL REFERENCES "order"(order_id),
	review_score SMALLINT NOT NULL,
	review_comment_title VARCHAR(200),
	review_comment_message VARCHAR(1000),
	review_creation_date TIMESTAMP,
	review_answer_timestamp TIMESTAMP,
	
	CONSTRAINT review_stars_con
		CHECK (review_score BETWEEN 0 AND 5)
);

COPY order_review FROM
	'C:\Users\KW\Desktop\Programowanie\SQL\Project - Brazilian e-commerce\Data\Main e-commerce data\Pre-processed data\olist_order_reviews_dataset_cleaned.csv'
		DELIMITER ','
			CSV HEADER;


/* ORDER_PAYMENT */
CREATE TABLE IF NOT EXISTS order_payment (
	order_id CHAR(32) /*PRIMARY KEY REFERENCES "order"(order_id)*/,
	payment_sequential SMALLINT NOT NULL,
	payment_type VARCHAR(30),
	payment_installments SMALLINT,
	payment_value DECIMAL NOT NULL,
	
	CONSTRAINT min_values
		CHECK (payment_value >= 0.0 AND payment_sequential > 0 AND payment_installments >= 0)
);

COPY order_payment FROM
	'C:\Users\KW\Desktop\Programowanie\SQL\Project - Brazilian e-commerce\Data\Main e-commerce data\Pre-processed data\olist_order_payments_dataset_cleaned.csv'
		DELIMITER ','
			CSV HEADER;


/* ORDER_ITEM */
CREATE TABLE IF NOT EXISTS order_item (
	order_id CHAR(32) NOT NULL REFERENCES "order"(order_id),
	order_item_id SMALLINT NOT NULL,
	product_id CHAR(32) NOT NULL REFERENCES product(product_id),
	seller_id CHAR(32) NOT NULL REFERENCES seller(seller_id),
	shipping_limit_date TIMESTAMP NOT NULL,
	price DECIMAL NOT NULL,
	freight_value DECIMAL,
	
	CONSTRAINT order_item_pk
		PRIMARY KEY (order_id, product_id, seller_id, order_item_id),
	CONSTRAINT minimal_values
		CHECK (order_item_id > 0 AND price >= 0.0 AND freight_value >= 0.0)
);

COPY order_item FROM
	'C:\Users\KW\Desktop\Programowanie\SQL\Project - Brazilian e-commerce\Data\Main e-commerce data\Pre-processed data\olist_order_items_dataset_cleaned.csv'
		DELIMITER ','
			CSV HEADER;
			
COMMIT;		
			