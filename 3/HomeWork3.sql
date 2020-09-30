/* Основная часть: */
/* выведите магазины, имеющие больше 300-от покупателей */

select store_id, count(customer_id) as customer_conut
from customer 
group by store_id
having count(customer_id)>300;


/* выведите у каждого покупателя город в котором он живет */

select concat(first_name,' ',last_name) as user_name, ct.city
from customer c
	join address a
		on c.address_id = a.address_id
	join city ct
		on a.address_id = ct.city_id
order by user_name;


/*Дополнительная часть: */
/* выведите ФИО сотрудников и города магазинов, имеющих больше 300-от покупателей */

select concat(st.first_name,' ',st.last_name) as staff_name, ct.city
from store s
	join address a
		on s.address_id = a.address_id
	join city ct
		on a.address_id = ct.city_id
	join staff st
		on s.store_id=st.store_id
where s.store_id in 
	(select store_id
	from customer 
	group by store_id
	having count(customer_id)>300);


/* выведите количество актеров, снимавшихся в фильмах, которые сдаются в аренду за 2,99 */

select count(distinct a.actor_id) as actors
from film f
	join film_actor a 
		on f.film_id=a.film_id
where f.rental_rate = 2.99;