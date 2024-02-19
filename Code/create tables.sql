/* Queries creating tables for the main part of the dataset. */

/* PRODUCT_CATEGORY_NAME_TRANSLATION */
CREATE TABLE product_category_name_translation (
	product_category_name datatype,
	product_category_name_english datatype
);

COPY product_category_name_translation FROM
	'"C:\Users\KW\Desktop\Programowanie\SQL\Projekt - Brazilian e-commerce\Dane\Część główna\product_category_name_translation.csv"'
		DELIMITER ','
			CSV HEADER;

/* SELLER */
CREATE TABLE seller (
	id datatype,
	zip_code datatype,
	
);

COPY seller FROM
	'"C:\Users\KW\Desktop\Programowanie\SQL\Projekt - Brazilian e-commerce\Dane\Część główna\olist_sellers_dataset.csv"'
		DELIMITER ',"'
			CSV HEADER;

/* PRODUCT */
CREATE TABLE product (
	 datatype,
	 datatype
);

COPY product FROM
	'"C:\Users\KW\Desktop\Programowanie\SQL\Projekt - Brazilian e-commerce\Dane\Część główna\olist_products_dataset.csv"'
		DELIMITER ',"'
			CSV HEADER;

/* ORDER */
CREATE TABLE order (
	 datatype,
	 datatype
);

COPY order FROM
	'"C:\Users\KW\Desktop\Programowanie\SQL\Projekt - Brazilian e-commerce\Dane\Część główna\olist_orders_dataset.csv"'
		DELIMITER ',"'
			CSV HEADER;

/* ORDER_REVIEW */
CREATE TABLE order_review (
	 datatype,
	 datatype
);

COPY order_reviews FROM
	'"C:\Users\KW\Desktop\Programowanie\SQL\Projekt - Brazilian e-commerce\Dane\Część główna\olist_order_reviews_dataset.csv"'
		DELIMITER ',"'
			CSV HEADER;

/* ORDER_PAYMENTS */
CREATE TABLE order_payments (
	 datatype,
	 datatype
);

COPY order_payments FROM
	'"C:\Users\KW\Desktop\Programowanie\SQL\Projekt - Brazilian e-commerce\Dane\Część główna\olist_order_payments_dataset.csv"'
		DELIMITER ',"'
			CSV HEADER;

/* ORDER_ITEM */
CREATE TABLE order_item (
	 datatype,
	 datatype
);

COPY order_item FROM
	'"C:\Users\KW\Desktop\Programowanie\SQL\Projekt - Brazilian e-commerce\Dane\Część główna\olist_order_items_dataset.csv"'
		DELIMITER ',"'
			CSV HEADER;

/* GEOLOCATION */
CREATE TABLE geolocation (
	 datatype,
	 datatype
);

COPY geolocation FROM
	'"C:\Users\KW\Desktop\Programowanie\SQL\Projekt - Brazilian e-commerce\Dane\Część główna\olist_geolocation_dataset.csv"'
		DELIMITER ',"'
			CSV HEADER;

/* CUSTOMER */
CREATE TABLE customer (
	 datatype,
	 datatype
);

COPY customer FROM
	'"C:\Users\KW\Desktop\Programowanie\SQL\Projekt - Brazilian e-commerce\Dane\Część główna\olist_customers_dataset.csv"'
		DELIMITER ',"'
			CSV HEADER;