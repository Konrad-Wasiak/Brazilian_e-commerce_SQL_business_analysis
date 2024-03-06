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
Before taking care of this issue, though, I'd like to cleanse the geegolocation table out of "junk data" first.
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
An example: Água Branca - state Alagoas and Água Branca - state Paraiba.
*/

/* Deduplicating */





