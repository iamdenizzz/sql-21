/* Перечислить все таблицы и первичные ключи в базе данных. Формат решения в виде таблицы: | Название таблицы | Первичный ключ | */

select kcu.table_name, kcu.column_name 
from information_schema.key_column_usage kcu 
	join information_schema.table_constraints tc
		on tc.constraint_name = kcu.constraint_name
	join information_schema.columns c
		on c.column_name = kcu.column_name
			and c.table_name = kcu.table_name
where tc.constraint_type = 'PRIMARY KEY'
order by kcu.table_name;

/* Вывести всех неактивных покупателей */

select concat(first_name,' ',last_name) as user_name from customer where active = '0';

/* Вывести все фильмы, выпущенные в 2006 году */

select title from film where release_year = '2006';

/* Вывести 10 последних платежей за прокат фильмов. */

select payment_id, customer_id, amount, payment_date from payment order by payment_date desc limit 10;

/* Самостоятельно прочитать про limit и offset в postgresql (например тут - http://www.postgresqltutorial.com/postgresql-limit/) */