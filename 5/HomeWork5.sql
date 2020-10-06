/*
База данных: dvd-rental

Основная часть:
    Сделайте запрос к таблице rental. Используя оконую функцию добавьте колонку с порядковым номером аренды для каждого пользователя (сортировать по rental_date)
*/

select  customer_id, 
		rental_id,
		row_number() over (partition by customer_id order by rental_date) as rental_num
from rental;

/*
    Для каждого пользователя подсчитайте сколько он брал в аренду фильмов со специальным атрибутом Behind the Scenes
    -напишите этот запрос
    -создайте материализованное представление с этим запросом
    -обновите материализованное представление
    -напишите три варианта условия для поиска Behind the Scenes
*/

select r.customer_id
from rental r
	join film f 
		on r.inventory_id = f.film_id
where f.special_features --> ;

/*
Дополнительная часть:
-открыть по ссылке sql запрос [https://letsdocode.ru/sql-hw5.sql], сделать explain analyze запроса
-основываясь на описании запроса, найдите узкие места и опишите их
-сравните с Вашим запросом из основной части (если Ваш запрос изначально укладывается в 15мс - отлично!)
-оптимизируйте запрос, сократив время обработки до максимум 15мс
-сделайте построчное описание explain analyze на русском языке оптимизированного запроса. Описание строк в explain можно посмотреть тут - [https://use-the-index-luke.com/sql/explain-plan/postgresql/operations]
*/