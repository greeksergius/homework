# Домашнее задание к занятию 12.5 "Реляционные базы данных: Индексы"

# Выполнил: Григорьев Сергей

---

Задание можно выполнить как в любом IDE, так и в командной строке.

### Задание 1.

Напишите запрос к учебной базе данных, который вернет процентное отношение общего размера всех индексов к общему размеру всех таблиц.

#### ОТВЕТ

> ЗАПРОС:
```
SELECT table_schema "DB Sakila data info", 
#Round(Sum(data_length ) / 1024 / 1024, 1) "Table Size in MB",
#Round(Sum(index_length) / 1024 / 1024, 1) "Index Size in MB",
round(((100/(round(((Sum(data_length)) / 1024 / 1024), 2)))*(round(((Sum(index_length)) / 1024 / 1024), 2))), 2) `Общее отношение всех индексов к размеру таблиц в %`
FROM   information_schema.tables  where table_schema = 'j12149682_sakila';
```
![Alt text](https://github.com/greeksergius/homework/blob/main/12-5%20sql%20index/2022-10-23_12-13-17.png)

```

> ЗАПРОС:
# Показываем общее по дате и индексам таблиц (для себя)
SELECT
   #  table_schema as `Database`,
     table_name AS `Table`,
     round(((data_length) / 1024 / 1024), 2) `Size in MB DATA lenght`,
     round(((index_length) / 1024 / 1024), 2) `Size in MB INDEX lenght`,
     round(((100/(round(((data_length) / 1024 / 1024), 2)))*(round(((index_length) / 1024 / 1024), 2))), 2) `Percentage`
     # round(((data_length + index_length) / 1024 / 1024), 2) `Size in MB`
FROM information_schema.TABLES where table_schema = 'j12149682_sakila'
group by table_name  ORDER BY data_length, index_length DESC;
```

### Задание 2.

Выполните explain analyze следующего запроса:
```sql
select distinct concat(c.last_name, ' ', c.first_name), sum(p.amount) over (partition by c.customer_id, f.title)
from payment p, rental r, customer c, inventory i, film f
where date(p.payment_date) = '2005-07-30' and p.payment_date = r.rental_date and r.customer_id = c.customer_id and i.inventory_id = r.inventory_id
```
- перечислите узкие места,
- оптимизируйте запрос (внесите корректировки по использованию операторов, при необходимости добавьте индексы).


#### ОТВЕТ

> ЗАПРОС:
```
select concat(c.last_name, ' ', c.first_name), sum(p.amount)
from payment p, rental r, customer c
where date(p.payment_date) = '2005-07-30' and p.payment_date = r.rental_date and r.customer_id = c.customer_id 
group by c.customer_id;
# Исходя из того, что на лекции говорилось, что distinct может отключать индексы, то убираем его из запроса и группируем по айди покупателя, убираем оператор OVER с partitions, тогда у нас нет необходимости считать каждую группу отдельно по c.customer_id и мы делаем подсчет один раз как единую партицию, а не по каждому c.customer_id, а группируем group by c.customer_id
# Убираем из оператора Over f.title и запрос данных из таблицы film т.к. данные ответа запроса в селекте не предпологают заголовки фильмов.
# Также  убираем обращение  к таблице inventory и обращение  inventory_id т.к. они так же не учавствуют в фильтрации данных и на результаты выдачи не влияют
```
![Alt text](https://github.com/greeksergius/homework/blob/main/12-5%20sql%20index/2022-10-23_12-13-17.png)




## Дополнительные задания (со звездочкой*)
Эти задания дополнительные (не обязательные к выполнению) и никак не повлияют на получение вами зачета по этому домашнему заданию. Вы можете их выполнить, если хотите глубже и/или шире разобраться в материале.

### Задание 3*.

Самостоятельно изучите, какие типы индексов используются в PostgreSQL. Перечислите те индексы, которые используются в PostgreSQL, а в MySQL нет.

*Приведите ответ в свободной форме.*

#### ОТВЕТ

![Alt text](https://github.com/greeksergius/homework/blob/main/12-5%20sql%20index/2022-10-23_14-21-15.png)

https://habr.com/ru/post/102785/
