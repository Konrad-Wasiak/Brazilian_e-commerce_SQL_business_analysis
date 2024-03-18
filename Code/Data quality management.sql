/*
At this step, I'm going to solve the issues mentioned at the beginning of "create tables.sql",
along with further examining the character of the data in the context of its quality and picking the right approach
for analysis.
*/

/*
PROBLEM 1, geolocation:
While trying to add a foreign key referencing the geolocation table to other tables,
it turned out that the table doesn't contain all the necessary locations.
*/

/*
Before taking care of this issue, though, I'd like to cleanse geo-related stuff out of "junk data" first.
*/

/*
A quick look at the data - sometimes even simple queries can help spot problems.
*/
SELECT DISTINCT geolocation_city, geolocation_state
	FROM geolocation
		ORDER BY 1,2
			LIMIT 200;	
/*
Turns out there are many duplicates as a result of typos / inconsistent typing -
- e.g., city Água Comprida is also present with "a" deprived of a diacritical mark.

Interestingly, there are cities with the same name but different states.
However, after further research, I discovered that it's not an error -
- there are cities with the same name in different states, Brazil is a huge country.
An example: Água Branca - state Alagoas, Água Branca - state Paraiba.
*/

/* Deduplicating */

/* Display */
SELECT geolocation_city
	FROM geolocation
		/* The data doesn't contain any uppercase diacritical marks. */
		WHERE geolocation_city SIMILAR TO '%(á|é|í|ó|ú)%';
		
/* Update */
BEGIN;
/* Temporarily dropping the primary key constraint, to successfully update despite of duplicates. */
	ALTER TABLE geolocation
		DROP CONSTRAINT geolocation_pkey;
	UPDATE geolocation
		SET geolocation_city = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LOWER(geolocation_city), 'á', 'a'), 'é', 'e'), 'í', 'i'), 'ó', 'o'), 'ú', 'u');
		
	/* Deleting duplicated rows with the use of CTE. */
	WITH CTE AS (
		SELECT *, ROW_NUMBER()
			OVER (
					PARTITION BY geolocation_zip_code_prefix, geolocation_city, geolocation_state
						ORDER BY geolocation_zip_code_prefix, geolocation_city, geolocation_state
				 ) AS rowNumber
			FROM geolocation
	)
	DELETE FROM geolocation 
		WHERE (geolocation_zip_code_prefix, geolocation_city, geolocation_state) IN (
			SELECT geolocation_zip_code_prefix, geolocation_city, geolocation_state
				FROM CTE
					WHERE rowNumber > 1
		);
	
	/* Re-adding the primary key constraint. */
	ALTER TABLE geolocation
		ADD PRIMARY KEY (geolocation_zip_code_prefix, geolocation_city, geolocation_state);

/* The same step is applied to seller and customer tables, since they're also related to geolocation. */
	UPDATE seller
		SET seller_city = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LOWER(seller_city), 'á', 'a'), 'é', 'e'), 'í', 'i'), 'ó', 'o'), 'ú', 'u');
	UPDATE customer
		SET customer_city = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LOWER(customer_city), 'á', 'a'), 'é', 'e'), 'í', 'i'), 'ó', 'o'), 'ú', 'u');

/* With the columns relating to geolocation being cleansed, I'm taking care of the missing records. */
/* Display */
SELECT customer_city, customer_state, customer_zip_code_prefix
	FROM geolocation
		RIGHT OUTER JOIN customer
			ON geolocation_city = customer_city AND geolocation_state = customer_state AND geolocation_zip_code_prefix = customer_zip_code_prefix
				WHERE geolocation_city IS NULL AND geolocation_state IS NULL AND geolocation_zip_code_prefix IS NULL;

/*
There are over 318 missing entities in 'geolocation' after outer joining it on 'customer'. 
They're inserted below.
*/
INSERT INTO geolocation
	SELECT DISTINCT customer_zip_code_prefix, customer_city, customer_state
		FROM geolocation
			RIGHT OUTER JOIN customer
				ON geolocation_city = customer_city AND geolocation_state = customer_state AND geolocation_zip_code_prefix = customer_zip_code_prefix
					WHERE geolocation_city IS NULL AND geolocation_state IS NULL AND geolocation_zip_code_prefix IS NULL;
				
/* Applying the same for the seller table: */

INSERT INTO geolocation
	SELECT DISTINCT seller_zip_code_prefix, seller_city, seller_state
		FROM geolocation
			RIGHT OUTER JOIN seller
				ON geolocation_city = seller_city AND geolocation_state = seller_state AND geolocation_zip_code_prefix = seller_zip_code_prefix
					WHERE geolocation_city IS NULL AND geolocation_state IS NULL AND geolocation_zip_code_prefix IS NULL;
COMMIT;

/* Problem 2: zmienić primary key na obydwa customer id w customer table. */












