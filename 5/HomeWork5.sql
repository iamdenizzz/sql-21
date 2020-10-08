/*
База данных: dvd-rental
Основная часть:
    Сделайте запрос к таблице rental. Используя оконую функцию добавьте колонку с порядковым номером аренды для каждого пользователя (сортировать по rental_date)
*/

select  customer_id,
		rental_id,
		row_number() over (partition by customer_id order by rental_date) as rental_num
from rental;


/* Для каждого пользователя подсчитайте сколько он брал в аренду фильмов со специальным атрибутом Behind the Scenes */
/* напишите этот запрос */

select c.customer_id, concat(c.first_name,' ',c.last_name) as user_name, count(f.film_id) as cnt
from rental r
	join inventory i
		on r.inventory_id = i.inventory_id 
	join film f 
		on i.film_id = f.film_id
	join customer c 
		on r.customer_id = c.customer_id
where 'Behind the Scenes' = any(f.special_features)
group by c.customer_id
order by cnt desc;


/* создайте материализованное представление с этим запросом */

create materialized view rental_film_osipov
as
select r.customer_id, count(f.film_id) as cnt
from rental r
	join inventory i
		on r.inventory_id = i.inventory_id 
	join film f 
		on i.film_id = f.film_id
where 'Behind the Scenes' = any(f.special_features)
group by r.customer_id
with no data;


/* обновите материализованное представление */

refresh materialized view rental_film_osipov;

select * from rental_film_osipov order by cnt desc;


/* напишите три варианта условия для поиска Behind the Scenes */

select count(r.customer_id)
from rental r
	join inventory i
		on r.inventory_id = i.inventory_id 
	join film f 
		on i.film_id = f.film_id
where 'Behind the Scenes' = any(f.special_features)

select count(r.customer_id)
from rental r
	join inventory i
		on r.inventory_id = i.inventory_id 
	join film f 
		on i.film_id = f.film_id
where 'Behind the Scenes' in (f.special_features[1], f.special_features[2], f.special_features[3], f.special_features[4]);

select count(r.customer_id)
from rental r
	join inventory i
		on r.inventory_id = i.inventory_id 
	join film f 
		on i.film_id = f.film_id
where concat(f.special_features) like '%Behind the Scenes%';

select count(r.customer_id)
from rental r
	join inventory i
		on r.inventory_id = i.inventory_id 
	join film f 
		on i.film_id = f.film_id
	join (select film_id, unnest(special_features) as feature from film) as sf
		on sf.film_id = f.film_id
where sf.feature = 'Behind the Scenes';


/* Дополнительная часть:
открыть по ссылке sql запрос [https://letsdocode.ru/sql-hw5.sql], сделать explain analyze запроса */

explain analyze select distinct cu.first_name  || ' ' || cu.last_name as name, 
	count(ren.iid) over (partition by cu.customer_id)
from customer cu
full outer join 
	(select *, r.inventory_id as iid, inv.sf_string as sfs, r.customer_id as cid
	from rental r 
	full outer join
		(select *, unnest(f.special_features) as sf_string
		from inventory i
		full outer join film f on f.film_id = i.film_id) as inv 
		on r.inventory_id = inv.inventory_id) as ren 
	on ren.cid = cu.customer_id 
where ren.sfs like '%Behind the Scenes%'
order by count desc;


/* 
Вывод explain:
--------------------------------------------------------
Unique  (cost=8598.88..8599.22 rows=46 width=44) (actual time=42.785..44.405 rows=600 loops=1)
  ->  Sort  (cost=8598.88..8598.99 rows=46 width=44) (actual time=42.784..43.369 rows=8632 loops=1)
        Sort Key: (count(r.inventory_id) OVER (?)) DESC, ((((cu.first_name)::text || ' '::text) || (cu.last_name)::text))
        Sort Method: quicksort  Memory: 1058kB
        ->  WindowAgg  (cost=8596.57..8597.61 rows=46 width=44) (actual time=31.645..38.062 rows=8632 loops=1)
              ->  Sort  (cost=8596.57..8596.69 rows=46 width=21) (actual time=31.620..32.779 rows=8632 loops=1)
                    Sort Key: cu.customer_id
                    Sort Method: quicksort  Memory: 1057kB
                    ->  Nested Loop Left Join  (cost=8211.35..8595.30 rows=46 width=21) (actual time=8.633..28.148 rows=8632 loops=1)
                          ->  Hash Right Join  (cost=8211.07..8581.70 rows=46 width=6) (actual time=8.610..13.807 rows=8632 loops=1)
                                Hash Cond: (r.inventory_id = inv.inventory_id)
                                ->  Seq Scan on rental r  (cost=0.00..310.44 rows=16044 width=6) (actual time=0.009..1.609 rows=16044 loops=1)
                                ->  Hash  (cost=8210.50..8210.50 rows=46 width=4) (actual time=8.592..8.592 rows=2494 loops=1)
                                      Buckets: 4096 (originally 1024)  Batches: 1 (originally 1)  Memory Usage: 120kB
                                      ->  Subquery Scan on inv  (cost=76.50..8210.50 rows=46 width=4) (actual time=0.887..8.188 rows=2494 loops=1)
                                            Filter: (inv.sf_string ~~ '%Behind the Scenes%'::text)
                                            Rows Removed by Filter: 7274
                                            ->  ProjectSet  (cost=76.50..2484.25 rows=458100 width=710) (actual time=0.883..5.959 rows=9768 loops=1)
                                                  ->  Hash Full Join  (cost=76.50..159.39 rows=4581 width=63) (actual time=0.875..2.487 rows=4623 loops=1)
                                                        Hash Cond: (i.film_id = f.film_id)
                                                        ->  Seq Scan on inventory i  (cost=0.00..70.81 rows=4581 width=6) (actual time=0.014..0.426 rows=4581 loops=1)
                                                        ->  Hash  (cost=64.00..64.00 rows=1000 width=63) (actual time=0.850..0.851 rows=1000 loops=1)
                                                              Buckets: 1024  Batches: 1  Memory Usage: 104kB
                                                              ->  Seq Scan on film f  (cost=0.00..64.00 rows=1000 width=63) (actual time=0.017..0.485 rows=1000 loops=1)
                          ->  Index Scan using customer_pkey on customer cu  (cost=0.28..0.30 rows=1 width=17) (actual time=0.001..0.001 rows=1 loops=8632)
                                Index Cond: (r.customer_id = customer_id)
Planning time: 0.623 ms
Execution time: 44.688 ms
------------------------------------------------------- 
*/


/* 
основываясь на описании запроса, найдите узкие места и опишите их:
-------------------------------------------------------
Наиболее узкие места можно увидеть по параметру затраченного времени actual time и кол-ву задействованных строк rows.
Выберем несколько запросов с наибольшими значениями параметров:
- Hash  (cost=8210.50..8210.50 rows=46 width=4) (actual time=8.592..8.592 rows=2494 loops=1) - конструирование хэш-таблицы
- Nested Loop Left Join  (cost=8211.35..8595.30 rows=46 width=21) (actual time=8.633..28.148 rows=8632 loops=1) - вложенный цикл с left join 
- Hash Right Join  (cost=8211.07..8581.70 rows=46 width=6) (actual time=8.610..13.807 rows=8632 loops=1) - создание хэш-таблицы для right join для Hash Cond: (r.inventory_id = inv.inventory_id)
- WindowAgg  (cost=8596.57..8597.61 rows=46 width=44) (actual time=31.645..38.062 rows=8632 loops=1) - для оконной функции
- Sort  (cost=8596.57..8596.69 rows=46 width=21) (actual time=31.620..32.779 rows=8632 loops=1) - затрачивается на сортировку Sort Key: cu.customer_id
- Unique  (cost=8598.88..8599.22 rows=46 width=44) (actual time=42.785..44.405 rows=600 loops=1) - уникальные значения
- Sort  (cost=8598.88..8598.99 rows=46 width=44) (actual time=42.784..43.369 rows=8632 loops=1) - затрачивается на сортировку
-------------------------------------------------------------
Как можно увидеть выше много времени тратится на сортировку и циклы при объединении таблиц.
*/


/* сравните с Вашим запросом из основной части (если Ваш запрос изначально укладывается в 15мс - отлично!) */

explain analyse select c.customer_id, concat(c.first_name,' ',c.last_name) as user_name, count(f.film_id) as cnt
from rental r
	join inventory i
		on r.inventory_id = i.inventory_id 
	join film f 
		on i.film_id = f.film_id
	join customer c 
		on r.customer_id = c.customer_id
where 'Behind the Scenes' = any(f.special_features)
group by c.customer_id
order by cnt desc;

/*
Вывод explain для своего запроса:
--------------------------------------------------------
Sort  (cost=729.76..731.26 rows=599 width=44) (actual time=14.291..14.320 rows=599 loops=1)
  Sort Key: (count(f.film_id)) DESC
  Sort Method: quicksort  Memory: 71kB
  ->  HashAggregate  (cost=694.64..702.13 rows=599 width=44) (actual time=13.794..14.178 rows=599 loops=1)
        Group Key: c.customer_id
        ->  Hash Join  (cost=233.78..651.48 rows=8632 width=21) (actual time=1.977..12.025 rows=8608 loops=1)
              Hash Cond: (r.customer_id = c.customer_id)
              ->  Hash Join  (cost=211.30..606.19 rows=8632 width=6) (actual time=1.765..9.868 rows=8608 loops=1)
                    Hash Cond: (i.film_id = f.film_id)
                    ->  Hash Join  (cost=128.07..480.67 rows=16044 width=4) (actual time=1.360..7.002 rows=16044 loops=1)
                          Hash Cond: (r.inventory_id = i.inventory_id)
                          ->  Seq Scan on rental r  (cost=0.00..310.44 rows=16044 width=6) (actual time=0.004..1.570 rows=16044 loops=1)
                          ->  Hash  (cost=70.81..70.81 rows=4581 width=6) (actual time=1.340..1.340 rows=4581 loops=1)
                                Buckets: 8192  Batches: 1  Memory Usage: 234kB
                                ->  Seq Scan on inventory i  (cost=0.00..70.81 rows=4581 width=6) (actual time=0.005..0.655 rows=4581 loops=1)
                    ->  Hash  (cost=76.50..76.50 rows=538 width=4) (actual time=0.400..0.400 rows=538 loops=1)
                          Buckets: 1024  Batches: 1  Memory Usage: 27kB
                          ->  Seq Scan on film f  (cost=0.00..76.50 rows=538 width=4) (actual time=0.005..0.336 rows=538 loops=1)
                                Filter: ('Behind the Scenes'::text = ANY (special_features))
                                Rows Removed by Filter: 462
              ->  Hash  (cost=14.99..14.99 rows=599 width=17) (actual time=0.206..0.206 rows=599 loops=1)
                    Buckets: 1024  Batches: 1  Memory Usage: 38kB
                    ->  Seq Scan on customer c  (cost=0.00..14.99 rows=599 width=17) (actual time=0.008..0.109 rows=599 loops=1)
Planning time: 0.555 ms
Execution time: 14.408 ms 
------------------------------------------------------
Свой запрос в 15мс укладывается
*/


/* оптимизируйте запрос, сократив время обработки до максимум 15мс */

/*
1. Уберем из запроса ren выборку неиспользуемых данных в виде *
2. Вместо второй звездочки в inv поставим i.inventory_id
3. Меняем ren.sfs like '%Behind the Scenes%' на 'Behind the Scenes' = any(f.special_features)
4. Перенесем условие внутрь запроса inv - where 'Behind the Scenes' = any(f.special_features), чтобы убрать один из join и сделаем выборку с in
5. Сделаем рассчет кол-ва заказов в цикле ren, сгруппировав запрос по пользователю group by r.customer_id
В итоге получится вот такой запрос:
*/

explain analyze select distinct cu.first_name  || ' ' || cu.last_name as name, ren.cnt
from customer cu
full outer join
	(
		select count(r.inventory_id) as cnt, r.customer_id as cid
		from rental r 
		where r.inventory_id in 
		(
			select i.inventory_id
			from inventory i
				full outer join film f on f.film_id = i.film_id
			where 'Behind the Scenes' = any(f.special_features)
		)
		group by r.customer_id 
	) as ren
	on ren.cid = cu.customer_id 
order by cnt desc;

/* Вывод explain:
--------------------------------------------------------
Unique  (cost=755.39..759.88 rows=599 width=40) (actual time=8.248..8.407 rows=599 loops=1)
  ->  Sort  (cost=755.39..756.89 rows=599 width=40) (actual time=8.248..8.279 rows=599 loops=1)
        Sort Key: (count(r.inventory_id)) DESC, ((((cu.first_name)::text || ' '::text) || (cu.last_name)::text))
        Sort Method: quicksort  Memory: 71kB
        ->  Hash Full Join  (cost=708.19..727.76 rows=599 width=40) (actual time=7.585..7.820 rows=599 loops=1)
              Hash Cond: (cu.customer_id = r.customer_id)
              ->  Seq Scan on customer cu  (cost=0.00..14.99 rows=599 width=17) (actual time=0.009..0.065 rows=599 loops=1)
              ->  Hash  (cost=700.70..700.70 rows=599 width=10) (actual time=7.567..7.567 rows=599 loops=1)
                    Buckets: 1024  Batches: 1  Memory Usage: 33kB
                    ->  HashAggregate  (cost=688.72..694.71 rows=599 width=10) (actual time=7.416..7.494 rows=599 loops=1)
                          Group Key: r.customer_id
                          ->  Hash Semi Join  (cost=196.93..645.55 rows=8635 width=6) (actual time=1.932..5.973 rows=8608 loops=1)
                                Hash Cond: (r.inventory_id = i.inventory_id)
                                ->  Seq Scan on rental r  (cost=0.00..310.44 rows=16044 width=6) (actual time=0.012..1.352 rows=16044 loops=1)
                                ->  Hash  (cost=166.12..166.12 rows=2465 width=4) (actual time=1.911..1.911 rows=2471 loops=1)
                                      Buckets: 4096  Batches: 1  Memory Usage: 119kB
                                      ->  Hash Join  (cost=83.22..166.12 rows=2465 width=4) (actual time=0.568..1.621 rows=2471 loops=1)
                                            Hash Cond: (i.film_id = f.film_id)
                                            ->  Seq Scan on inventory i  (cost=0.00..70.81 rows=4581 width=6) (actual time=0.006..0.383 rows=4581 loops=1)
                                            ->  Hash  (cost=76.50..76.50 rows=538 width=4) (actual time=0.556..0.556 rows=538 loops=1)
                                                  Buckets: 1024  Batches: 1  Memory Usage: 27kB
                                                  ->  Seq Scan on film f  (cost=0.00..76.50 rows=538 width=4) (actual time=0.010..0.470 rows=538 loops=1)
                                                        Filter: ('Behind the Scenes'::text = ANY (special_features))
                                                        Rows Removed by Filter: 462
Planning time: 0.541 ms
Execution time: 8.514 ms */


/* сделайте построчное описание explain analyze на русском языке оптимизированного запроса.*/

/*
 Описание строк (снизу вверх):
 1. Seq Scan on film f - построчная выборка данных из таблицы film, фильтром было отброшено 462 строки
 2. Построчное чтение inventory i
 3. Хэширование для объединения таблиц (i.film_id = f.film_id)
 4. Построчное чтение rental r
 5. Хэширование для объединения таблиц (r.inventory_id = i.inventory_id)
 6. Группировка данных по r.customer_id
 7. Построчное чтение customer cu
 8. Хэширование для объединения таблиц (cu.customer_id = r.customer_id)
 9. Сортировка по (count(r.inventory_id))
*/