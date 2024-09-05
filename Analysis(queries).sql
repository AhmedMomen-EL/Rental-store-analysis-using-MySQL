# Top categories rented
SELECT cat.name, COUNT(r.rental_id)
FROM rental r
LEFT JOIN inventory i
ON r.inventory_id= i.inventory_id
JOIN film f
ON f.film_id = i.film_id
JOIN film_category fcat
ON fcat.film_id = f.film_id
JOIN category cat
ON cat.category_id = fcat.category_id
group by name
order by 2 desc;


# The total revenue per year
SELECT SUM(p.amount) AS year , LEFT(rental_date,4) AS date
FROM payment p
JOIN RENTAL r
ON r.rental_id = p.rental_id
GROUP BY 2
order by 2


# movies haven't been rented in the last 3 months
SELECT f.title, cat.name category_name, f.last_update, COUNT(cat.name) count
FROM rental r
RIGHT OUTER JOIN inventory i
ON r.inventory_id= i.inventory_id
JOIN film f
ON f.film_id = i.film_id
JOIN film_category fcat
ON fcat.film_id = f.film_id
JOIN category cat
ON cat.category_id = fcat.category_id
WHERE f.last_update >= DATE_SUB( '2006-02-14' , INTERVAL 3 month ) 
GROUP BY 1,2,3
ORDER BY 3 DESC;



# Who has rented at least 30 times
SELECT CONCAT (first_name, ' ' , last_name) AS name , COUNT(r.customer_id) AS number_of_times
FROM customer c
JOIN rental r
ON c.customer_id = r.customer_id
GROUP BY 1
having number_of_times >= 30
ORDER BY 2 DESC;


# Movies Ranked based on the revenue they got
SELECT cat.name category, SUM(p.amount) profit
FROM rental r
LEFT JOIN inventory i
ON r.inventory_id= i.inventory_id
JOIN payment p
ON r.rental_id = p.rental_id
JOIN film f
ON f.film_id = i.film_id
JOIN film_category fcat
ON fcat.film_id = f.film_id
JOIN category cat
ON cat.category_id = fcat.category_id
group by 1
order by 2 desc;


# Most participated actors in the top 100 movies rented of all time
WITH T1 AS (SELECT f.film_id, f.title AS title , COUNT(r.rental_id) AS times_rented
FROM film f
JOIN inventory i
ON f.film_id= i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 100)
SELECT CONCAT(first_name, ' ' , last_name) name , T1.title , T1.times_rented
FROM actor a
JOIN film_actor fact
ON a.actor_id = fact.actor_id
JOIN film f
ON f.film_id = fact.film_id
JOIN T1
ON f.film_id= T1.film_id


# Number of unique renters we have per month
SELECT  month,COUNT(customer_id) unique_renters
FROM(
SELECT DISTINCT c.customer_id AS customer_id , CONCAT(first_name, ' ' , last_name) name, DATE_FORMAT(r.rental_date,'%y-%m') month
FROM customer c
RIGHT JOIN rental r
ON c.customer_id = r.customer_id
ORDER BY 3
) sub
GROUP BY 1
ORDER BY 1  


# Cities that have the highest renting requests
SELECT city.city , COUNT(r.rental_id) number_of_rentals
FROM rental r
LEFT JOIN  customer c
ON c.customer_id = r.customer_id
JOIN address a
ON a.address_id = c.address_id
JOIN city 
ON city.city_id = a.city_id
GROUP BY 1
ORDER BY 2 DESC


# Show rental data of customers, names and address
SELECT  CONCAT(first_name,' ',last_name) name , r.rental_date , a.address
FROM rental r
JOIN  customer c
ON c.customer_id = r.customer_id
JOIN address a
ON a.address_id = c.address_id


# Top contries in number of rentals
SELECT country.country , COUNT(r.rental_id) rentals_number
FROM rental r
LEFT JOIN  customer c
ON c.customer_id = r.customer_id
JOIN address a
ON a.address_id = c.address_id
JOIN city 
ON city.city_id = a.city_id
JOIN country 
ON country.country_id = city.country_id
GROUP BY 1
ORDER BY 2 DESC


# Cleaning (Create dummy valriable for special featuers from film table)
WIth t1 AS (SELECT SUBSTRING_INDEX(special_features, ',' , 1) AS first,                                           ## using sybstring_index to split columns  
       SUBSTRING_INDEX(SUBSTRING_INDEX(special_features, ',' , 2),',' , -1) AS mid ,
	   SUBSTRING_INDEX(special_features, ',' , -1) AS last_name ,
       SUBSTRING_INDEX(SUBSTRING_INDEX(special_features, ',' , -2),',' , 1) AS after_mid                          ## but still need to be adjusted 
       
FROM film)
SELECT first,
       CASE when t1.mid = t1.first then 'null' ELSE t1.mid END AS middle,                                         ## Adjusting rows to have only one unique value in each column and null if repeated
       CASE when t1.last_name = t1.mid then 'null' ELSE t1.last_name END AS last,
       CASE when t1.after_mid = t1.last_name then 'null' ELSE t1.after_mid END AS after_mid
       FROM t1;


# See how many file we have in each special feature type
select *
from film 
where special_features like "%Deleted Scenes%";


# Another approach to see how many films we have in each special feature type
WIth t1 AS (SELECT SUBSTRING_INDEX(special_features, ',' , 1) AS first,                                           ## using sybstring_index to split columns  
       SUBSTRING_INDEX(SUBSTRING_INDEX(special_features, ',' , 2),',' , -1) AS mid ,
	   SUBSTRING_INDEX(special_features, ',' , -1) AS last_name ,
       SUBSTRING_INDEX(SUBSTRING_INDEX(special_features, ',' , -2),',' , 1) AS after_mid                          ## but still need to be adjusted 
       
FROM film),
t2 AS (SELECT first,
       CASE when t1.mid = t1.first then 'null' ELSE t1.mid END AS middle,                                         ## Adjusting rows to have only one unique value in each column and null if repeated
       CASE when t1.last_name = t1.mid then 'null' ELSE t1.last_name END AS last,
       CASE when t1.after_mid = t1.last_name then 'null' ELSE t1.after_mid END AS after_mid
       FROM t1)  
 SELECT sum(CASE when t2.first = 'Deleted Scenes' THEN 1
            when t2.middle = 'Deleted Scenes' THEN 1
            when t2.last = 'Deleted Scenes' THEN 1
            when t2.after_mid = 'Deleted Scenes' THEN 1
            ELSE 0 END) AS Count_Deleted_Scenes_films
FROM t2   



# Rating and Total number of films for each store
SELECT s.store_id, f.rating, COUNT(f.rating) AS total_number_of_films
FROM store s
JOIN inventory i 
ON s.store_id = i.store_id
JOIN film f 
ON f.film_id = i.film_id
GROUP BY 1,2;
         