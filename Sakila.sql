
-- Anthony Elkadi 
-- Case Western Reserve - Data Analytics

-- 1a.) Display the first and last names of all actors from the table actor.
USE sakila;
SELECT actor.first_name, actor.last_name
FROM actor;

-- 1b.) Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(first_name, ' ', last_name) AS actor_name FROM actor;

-- 2a.) You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query you would use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor WHERE first_name LIKE 'Joe%';

-- 2b.) Find all actors whose last name contain the letters GEN:
SELECT first_name, last_name FROM actor
WHERE last_name LIKE "%Gen%";

-- 2c.) Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:
SELECT first_name, last_name FROM actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name, first_name; 

-- 2d.) Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id,  country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a.) Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
SELECT * FROM actor;
ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(50) AFTER first_name;

-- 3b.) You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
ALTER TABLE actor 
MODIFY COLUMN middle_name BLOB;
SELECT * FROM actor;

-- 3c.) Now delete the middle_name column.
ALTER TABLE actor
DROP COLUMN middle_name;

-- 4a.) List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) AS `Count`
FROM actor
GROUP BY last_name;

-- 4b.) List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) AS `Count`
FROM actor
GROUP BY last_name
HAVING Count >= 2;

-- 4c.) The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO' 
WHERE first_name = 'GROUCHO' AND last_name = "WILLIAMS";

-- 4d.) Perhaps we were too hasty in changing GROUCHO to HARPO. 
-- It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor 
SET first_name = "GROUCHO"
WHERE first_name = "HARPO" AND last_name = "WILLIAMS";

-- 5a.) You cannot locate the schema of the address table. Which query would you use to re-create it?
DESCRIBE sakila.address;

-- 6a.) Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT a.first_name, a.last_name, b.address
FROM staff a LEFT JOIN address b ON a.address_id = b.address_id;

-- 6b.) Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT a.first_name, a.last_name, SUM(b.amount) AS 'TOTAL'
FROM staff a LEFT JOIN payment b ON a.staff_id = b.staff_id
WHERE payment_date LIKE "%2005-08%"
GROUP BY first_name, last_name; 

-- 6c.) List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT a.title, COUNT(actor_id) AS 'TOTAL'
FROM film a LEFT JOIN film_actor b ON a.film_id = b.film_id
GROUP BY a.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(film_id) FROM inventory
WHERE film_id IN 
(SELECT film_id from film
WHERE title = "Hunchback Impossible");
-- ANSWER = 6

-- 6e.) Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT a.first_name, a.last_name, SUM(b.amount) AS 'TOTAL PAID'
FROM customer a LEFT JOIN payment b ON a.customer_id = b.customer_id
GROUP BY a.first_name, a.last_name
ORDER BY a.last_name; 

-- 7a.) The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title FROM film 
WHERE (title LIKE 'K%' OR title LIKE 'Q%')
AND language_id = (SELECT language_id FROM language where name = "English");

-- 7b.) Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name FROM actor 
WHERE actor_id 
	IN (SELECT actor_id FROM film_actor WHERE film_id 
		IN (SELECT film_id FROM film WHERE title = "Alone Trip"));
        
 -- 7c.) You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.       
SELECT first_name, last_name, email
FROM customer a
JOIN address b ON (a.address_id = b.address_id)
JOIN city c ON (b.city_id = c.city_id)
JOIN country d ON (c.country_id = d.country_id)
WHERE d.country_id = 20;

-- 7d.) Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT title,rating FROM film 
WHERE (rating LIKE "G%" OR rating LIKE "PG%");

-- 7e.) Display the most frequently rented movies in descending order.
SELECT title, rental_rate FROM film
ORDER BY rental_rate DESC;

-- 7f.) Write a query to display how much business, in dollars, each store brought in.
SELECT a.store_id, SUM(b.amount) AS "Total Sales"
FROM payment b
JOIN staff a ON (b.staff_id = a.staff_id)
GROUP BY store_id;

-- 7g.) Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country FROM store a 
JOIN address b ON (a.address_id = b.address_id)
JOIN city c ON (b.city_id = c.city_id)
JOIN country d ON (c.country_id = d.country_id);

-- 7h.) List the top five genres in gross revenue in descending order. 
SELECT a.name AS "TOP FIVE", SUM(e.amount) AS "Revenue"
FROM category a
JOIN film_category b ON (a.category_id = b.category_id)
JOIN inventory c ON (b. film_id = c.film_id)
JOIN rental d ON (c.inventory_id = d.inventory_id)
JOIN payment e ON (d.rental_id = e.rental_id)
GROUP BY a.name ORDER BY Revenue LIMIT 5;

-- 8a.) In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view.
CREATE VIEW Top_5_Genres AS
SELECT a.name AS "TOP FIVE", SUM(e.amount) AS "Revenue"
FROM category a
JOIN film_category b ON (a.category_id = b.category_id)
JOIN inventory c ON (b. film_id = c.film_id)
JOIN rental d ON (c.inventory_id = d.inventory_id)
JOIN payment e ON (d.rental_id = e.rental_id)
GROUP BY a.name ORDER BY Revenue LIMIT 5;

-- 8b.) How would you display the view that you created in 8a?
SELECT * FROM top_5_genres;

-- 8c.) You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_5_genres;

