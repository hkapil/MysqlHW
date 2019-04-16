use sakila;

# 1a. Display the first and last names of all actors from the table actor.

select first_name,last_name 
from actor;

# 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

select Concat (Upper(first_name) ," ", upper(last_name)) as "Actor Name" 
from actor;

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

select actor_id, first_name, last_name 
from actor
where first_name = "Joe";

#2b. Find all actors whose last name contain the letters GEN:

select actor_id, first_name, last_name 
from actor
where last_name like "%GEN%";

#2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

select actor_id,  last_name, first_name 
from actor
where last_name like "%LI%" 
order by last_name, first_name;

#2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

select country_id, country 
from country
where country in ( 'Afghanistan', 'Bangladesh',  'China');

#3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

alter table actor
add column description blob;

#3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.

alter table actor
drop column description;

#4a. List the last names of actors, as well as how many actors have that last name.

select distinct last_name, count(*) 
from actor
group by last_name;

#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

select distinct last_name, count(*) 
from actor
group by last_name
having count(*)>=2;

#4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.

update actor
set first_name = 'HARPO'
where first_name = 'GROUCHO' and last_name ='WILLIAMS';

#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.

update actor
set first_name = 'GROUCHO'
where first_name = 'HARPO' and last_name ='WILLIAMS';

#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`));
  
#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

select first_name, last_name, address, address2, district, city,postal_code
from staff, address, city
where 	staff.address_id = address.address_id and
		address.city_id = city.city_id;
        
#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

select distinct staff.first_name, staff.last_name, sum(amount)
from staff
inner join payment
on staff.staff_id =payment.staff_id
group by staff.first_name, staff.last_name;

#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

select distinct film.title, count(film_actor.actor_id)
from film
inner join film_actor
on film.film_id = film_actor.film_id
group by  film.title;


#6d. How many copies of the film Hunchback Impossible exist in the inventory system?

select distinct film.title, count(*) as "#copies in Inventory"
from film
inner join inventory
on film.film_id = inventory.film_id
group by film.title;

#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:

select distinct  customer.last_name, customer.first_name,sum(amount) as "Total Amount Paid"
from Customer
inner join Payment
on customer.customer_id = payment.customer_id
group by customer.first_name, customer.last_name
order by customer.last_name;


#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

select film.title
from film
where 
title in 
(Select title 
from film 
where language_id = 1 
and title like ('K%') or title like ('Q%')
);

#7b. Use subqueries to display all actors who appear in the film Alone Trip.

select first_name, last_name 
from actor
where actor_id in
(select actor_id 
from film_actor 
where film_id in
(select film_id 
from film
where title = 'Alone Trip')
);

#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

select first_name, last_name,email 
from customer
where address_id in
(select address_id 
from address
where city_id in
(select city_id 
from city where
country_id in
(select country_id 
from country 
where country ='Canada'
)
)
);

#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

select title
from film, film_category, category
where film.film_id = film_category.film_id
and film_category.category_id = category.category_id
and category.name='Family';

#7e. Display the most frequently rented movies in descending order.

select distinct  film.title, count(*) as "# Of Times Rented"
from rental, inventory, film
where rental.inventory_id =  inventory.inventory_id
and inventory.film_id = film.film_id
group by  film.title
order by count(*) desc;

#7f. Write a query to display how much business, in dollars, each store brought in.

select * from sales_by_store;

#Alternate solution using base tables:
 SELECT CONCAT(`c`.`city`, _UTF8',', `cy`.`country`) AS `Store`,
        CONCAT(`m`.`first_name`,
                _UTF8' ',
                `m`.`last_name`) AS `Manager`,
                replace(concat('$', format( SUM(`p`.`amount`),2)), '$-', '-$') as 'Total Sales'
    FROM
        (((((((`payment` `p`
        JOIN `rental` `r` ON ((`p`.`rental_id` = `r`.`rental_id`)))
        JOIN `inventory` `i` ON ((`r`.`inventory_id` = `i`.`inventory_id`)))
        JOIN `store` `s` ON ((`i`.`store_id` = `s`.`store_id`)))
        JOIN `address` `a` ON ((`s`.`address_id` = `a`.`address_id`)))
        JOIN `city` `c` ON ((`a`.`city_id` = `c`.`city_id`)))
        JOIN `country` `cy` ON ((`c`.`country_id` = `cy`.`country_id`)))
        JOIN `staff` `m` ON ((`s`.`manager_staff_id` = `m`.`staff_id`)))
    GROUP BY `s`.`store_id`
    ORDER BY `cy`.`country` , `c`.`city`;


#7g. Write a query to display for each store its store ID, city, and country.

SELECT `s`.`store_id`, `c`.`city`,  `cy`.`country` 
    FROM `store` `s`
        JOIN `address` `a` ON `s`.`address_id` = `a`.`address_id`
        JOIN `city` `c` ON `a`.`city_id` = `c`.`city_id`
        JOIN `country` `cy` ON `c`.`country_id` = `cy`.`country_id`;

#7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

Select * from 
(
select `cat`.`name`, replace(concat('$', format( SUM(`p`.`amount`),2)), '$-', '-$') as 'Gross Revenue' 
from `payment` `p`
	JOIN `rental` `r` ON `p`.`rental_id` = `r`.`rental_id`
	JOIN `inventory` `i` ON `r`.`inventory_id` = `i`.`inventory_id`
	JOIN `film_category` `fcat` ON `i`.`film_id` = `fcat`.`film_id`
    JOIN `category` `cat` ON `fcat`.`category_id` = `cat`.`category_id`
GROUP BY `cat`.`name`
ORDER BY SUM(`p`.`amount`) DESC) `genre_summary`
Limit 5;
    
        
#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
#Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

Create View Genre_summary as
Select * from 
(
select `cat`.`name`, replace(concat('$', format( SUM(`p`.`amount`),2)), '$-', '-$') as 'Gross Revenue' 
from `payment` `p`
	JOIN `rental` `r` ON `p`.`rental_id` = `r`.`rental_id`
	JOIN `inventory` `i` ON `r`.`inventory_id` = `i`.`inventory_id`
	JOIN `film_category` `fcat` ON `i`.`film_id` = `fcat`.`film_id`
    JOIN `category` `cat` ON `fcat`.`category_id` = `cat`.`category_id`
GROUP BY `cat`.`name`
ORDER BY SUM(`p`.`amount`) DESC) `genre_summary`
Limit 5;

#8b. How would you display the view that you created in 8a?

select * from genre_summary;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

Drop view genre_summary;