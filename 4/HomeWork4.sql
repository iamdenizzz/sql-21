/*Домашнее задание по теме “Углубление в SQL”

База данных: если подключение к облачной базе, то создаете новые таблицы в формате: таблица_фамилия, если подключение к контейнеру или локальному серверу, то создаете новую схему и в ней создаете таблицы.*/

/*Основная часть:
Спроектируйте базу данных для следующих сущностей:
-язык (в смысле английский, французский и тп)
-народность (в смысле славяне, англосаксы и тп)
-страны (в смысле Россия, Германия и тп)*/

/*Правила следующие:
-на одном языке может говорить несколько народностей
-одна народность может входить в несколько стран
-каждая страна может состоять из нескольких народностей*/

/*Суть задания - научиться проектировать архитектуру и работать с ограничениями. Таким образом должно получиться 5 таблиц. Три таблицы-справочника и две таблицы со связями.
(Пример таблицы со связями - film_actor)*/

/*Пришлите скрипты создания таблиц и скрипты по добавлению в каждую таблицу по 5 строк с данными*/

create schema peoples;

set search_path to peoples;

create  table languages(
id_language serial primary key,
language_name varchar(100)
);

create  table nationalities(
id_nationality serial primary key,
nationality varchar(100)
);

create  table countries(
id_country serial primary key,
country varchar(100)
);

create table lang_nation(
id_lang int,
id_nation int,
unique (id_lang, id_nation),
foreign key(id_lang) references languages(id_language),
foreign key(id_nation) references nationalities(id_nationality)
);

create table nation_countr(
id_nation int,
id_countr int,
unique (id_nation, id_countr),
foreign key(id_nation) references nationalities(id_nationality),
foreign key(id_countr) references countries(id_country)
);

insert into languages (language_name) values 
('Китайский'),('Английский'),('Испанский'),('Арабский'),('Русский'),('Португальский'),('Немецкий'),('Французский'),('Украинский'),('Польский'),('Сербский'),('Чешский');

insert into nationalities (nationality) values
('Славянские народы'),('Романские народы'),('Германские народы'),('Кельты'),('Тюрки'),('Тюрки');

insert into countries (country) values
('Россия'),('Германия'),('Англия'),('Франция'),('Украниа'),('Казахстан'),('Польша');

insert into lang_nation (id_lang, id_nation) values
(5,1), (3,2), (6,2), (7,3), (9,1);

insert into nation_countr (id_nation, id_countr) values
(1,1), (1,5), (1,7), (5,6), (3,2);

/*Дополнительная часть:
-показать, как назначать внешние ключи краткой записью при создании таблицы и как можно присвоить внешние ключи для столбцов существующей таблицы
-масштабировать получившуюся базу данных используя следующие типы данных: timestamp, boolean и text[]*/

create table lang_countr(
id_lang int,
id_countr int,
unique (id_lang, id_countr),
foreign key(id_lang) references languages(id_language)
);

alter table lang_countr add foreign key(id_countr) references countries(id_country);

alter table languages add column dates timestamp;

alter table nationalities add column in_europe boolean;

alter table countries add column params text [];