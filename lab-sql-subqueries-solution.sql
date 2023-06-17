-- 1. How many copies of the film Hunchback Impossible exist in the inventory system?

select f.title, count(i.inventory_id) from sakila.inventory i
join sakila.film f using (film_id)
where f.title = "Hunchback Impossible";

-- 2. List all films whose length is longer than the average of all the films.

select title, length from sakila.film
where length > (
	select avg(length) from sakila.film
	)
order by length desc; 

-- 3. Use subqueries to display all actors who appear in the film Alone Trip.

select a.first_name, a.last_name, ai.actor_id from sakila.actor a
join (
	select actor_id from sakila.film_actor
	where film_id = (
		select film_id from sakila.film
		where title = "Alone Trip"
		)
	) ai
using (actor_id);

-- 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

select f.title from sakila.film f
join (
	select film_id from sakila.film_category
	where category_id = (
		select category_id from sakila.category
		where name = "Family"
		)
	) fi 
using (film_id);

-- 5. Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.

-- with subqueries: 

-- query to get the country_id for Canada
select country_id from sakila.country
where country = "Canada";

-- query to get city_id of cities which have Canadian country_id

select city_id from sakila.city 
where country_id = (
	select country_id from sakila.country
	where country = "Canada"
	);

-- query to get the list of address_id with Canadian cities

select address_id from sakila.address
where city_id in (
	select city_id from sakila.city 
	where country_id = (
		select country_id from sakila.country
		where country = "Canada"
		)
	);
    
-- FINAL: query to get customer info for those with address_id in the above list:

select first_name, last_name, email from sakila.customer
where address_id in (
	select address_id from sakila.address
	where city_id in (
		select city_id from sakila.city 
		where country_id = (
			select country_id from sakila.country
			where country = "Canada"
			)
		)
	);


-- with joins:
select first_name, last_name, email, address_id from sakila.customer c
join (
	select a.address_id from sakila.address a
	join (
		select city_id from sakila.city
		where country_id = (
			select country_id from sakila.country
			where country = "Canada")
			) c
		using (city_id)
		) ai
using (address_id);

-- 6. Which are films starred by the most prolific actor? 
-- Most prolific actor is defined as the actor that has acted in the most number of films. 
-- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

-- to find prolific actor's ID:
select actor_id, count(film_id) from sakila.film_actor
group by actor_id
order by count(film_id) desc
limit 1;

-- to get the list of movies with this actor: 
select fa.film_id from sakila.film_actor fa
join (
	select actor_id, count(film_id) from sakila.film_actor
	group by actor_id
	order by count(film_id) desc
	limit 1
	) a 
using (actor_id);

-- FINAL: to get the titles of those movies: 
select f.title from sakila.film f
join (
	select fa.film_id from sakila.film_actor fa
	join (
		select actor_id, count(film_id) from sakila.film_actor
		group by actor_id
		order by count(film_id) desc
		limit 1
		) a 
	using (actor_id)
	) af
using (film_id);

-- 7. Films rented by most profitable customer. 
-- You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments

-- finding the most profitable customer:
select customer_id, sum(amount) from sakila.payment
group by customer_id
order by sum(amount) desc
limit 1;

-- finding the list of inventory_id rented by this customer
select inventory_id from sakila.rental
where customer_id = (
	select customer_id from sakila.payment
	group by customer_id
	order by sum(amount) desc
	limit 1
	);

-- getting the list of film_id based on inventory_id:

select i.film_id from sakila.inventory i
join (
	select inventory_id from sakila.rental
	where customer_id = (
		select customer_id from sakila.payment
		group by customer_id
		order by sum(amount) desc
		limit 1
		)
	) r
using (inventory_id);

-- FINAL: getting the titles of movies under those film_id: 

select f.title from sakila.film f
join (
	select i.film_id from sakila.inventory i
	join (
		select inventory_id from sakila.rental
		where customer_id = (
			select customer_id from sakila.payment
			group by customer_id
			order by sum(amount) desc
			limit 1
			)
		) r
		using (inventory_id)
	) fi
using (film_id);

-- 8. Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.

-- getting total amount per customer
select customer_id, sum(amount) as total_amount from sakila.payment
group by customer_id;

-- getting the average of total_amount
select avg(ta.total_amount) from (
	select customer_id, sum(amount) as total_amount from sakila.payment
	group by customer_id) as ta;

-- FINAL: getting customer_id and total_amount_spent of customers who spent more than the average of the total_amount spent by each client:

select customer_id, sum(amount) as total_amount from sakila.payment
group by customer_id
having total_amount > (
	select avg(ta.total_amount) from (
		select customer_id, sum(amount) as total_amount from sakila.payment
		group by customer_id
		) as ta
	)
order by total_amount desc;
