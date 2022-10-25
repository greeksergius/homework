# Домашнее задание к занятию 12.6 "Репликация и масштабирование. Часть 1"
# Выполнил: Григорьев Сергей.

---

### Задание 1.

На лекции рассматривались режимы репликации master-slave, master-master, опишите их различия.

*Ответить в свободной форме.*


#### ОТВЕТ
Репликация master-slave
Репликация типа Master-Slave часто используется для обеспечения отказоустойчивости приложений за счет горизонтального расширения. Кроме этого, она позволяет распределить нагрузку на базу данных между несколькими серверами (репликами), путем переноса запросов "ЧТЕНИЯ" (например через nginx) данных на слейв-сервера, а мастером допустим осуществлять записи в бд и последующие репликации по нодам.

Репликация Master-Master
Репликация master-master позволяет копировать данные с одного сервера на другой. Эта конфигурация добавляет избыточность и повышает эффективность при обращении к данным. Master-Master репликации – это настройка обычной Master-Slave репликации, только в обе стороны (каждый сервер является мастером и слейвом одновременно). Использование данного подхода позволяет эксплуатировать в работе "горячии" сервера, где одновременно пишутся и читаются данные.  

---

### Задание 2.

Выполните конфигурацию Master-Slave репликации (примером можно пользоваться из лекции).

*Приложите скриншоты конфигурации, выполнения работы (состояния и режимы работы серверов).*

#### ОТВЕТ

> Установка docker на Ubuntu:
```
apt update && apt install docker.io
 
```

> Установка и настройка docker container с mysql на Ubuntu:
```
docker search mysql
```
Скачиваем сборку
```
docker pull ubuntu/mysql
```
Смотрим все образы, которые есть у docker
```
docker images
```
Поднимаем контейнеры
```
docker run -d --name replication-master-ubuntu -e MYSQL_ALLOW_EMPTY_PASSWORD=true -v ~/path/to/world/dump:/docker-entrypoint-initdb.d ubuntu/mysql
docker run -d --name replication-slave-ubuntu -e MYSQL_ALLOW_EMPTY_PASSWORD=true ubuntu/mysql
```
Для работы контейнеров с друг другом создаем мост и сеть
```
docker network create replication
docker network connect replication replication-master-ubuntu
docker network connect replication replication-slave-ubuntu
```
Ставим редактор nano на два контейнера, для дальнейшего редактирования конфиг файлов mysql
```
docker exec replication-slave-ubuntu apt-get update && docker exec replication-slave-ubuntu apt-get install -y nano
docker exec replication-slave-ubuntu apt-get update && docker exec replication-slave-ubuntu apt-get install -y nano
```
Создадим учетную запись Master для сервера репликации:
```
docker exec -it replication-master-ubuntu mysql
```
В контейнере мастера создадим пользователя replication с правами  репликации на все базы:
```
mysql> CREATE USER 'replication'@'%';
mysql> GRANT REPLICATION SLAVE ON *.* TO 'replication'@'%';
mysql> FLUSH PRIVILEGES;
```
Изменим конфигурацию мастер сервера:
```
docker exec -it replication-master-ubuntu bash
nano /etc/mysql/my.cnf
```
Далее добавим настройки в конфиг после секции [mysqld] 
```
server_id = 1
log_bin = mysql-bin
```
![Alt text](https://github.com/greeksergius/homework/blob/main/12-6-sql-rep1/2022-10-25_13-02-42.png)

При изменении конфигурации сервера требуется перезагрузка:
```
docker restart replication-master-ubuntu
```
После требуется зайти в контейнер и проверить состояние:
```
docker exec -it replication-master-ubuntu mysql
mysql> SHOW MASTER STATUS;
```
Так как сборка у нас без тестовой БД World, то скачиваем ее и экспортируем в БД мастера репликации. Заходим в терминал контейнера и выполняем: 
```
apt-install wget 
wget https://downloads.mysql.com/docs/world-db.tar.gz
tar -xvf world-db.tar.gz
```
Заходим в mysql и создаем базу данных world
```
docker exec -it replication-master-ubuntu mysql
mysql>  CREATE DATABASE `world`;
```
Экспортируем дамп в  бд world
```
mysql world < путьгде файл/world.sql
```
Смотрим мастер статус
```
mysql> SHOW MASTER STATUS;
```
![Alt text](https://github.com/greeksergius/homework/blob/main/12-6-sql-rep1/2022-10-25_13-16-19.png)

Следующим шагом требуется выполнить слепок системы и заблокировать все изменения на мастер сервере:
```
mysql> FLUSH TABLES WITH READ LOCK;
```
После данных манипуляций выхода из контейнера и выполняем процесс mysqldump для экспорта базы данных, например:
```
docker exec replication-master-ubuntu mysqldump world > /путьна вашем рабочем терминале /world.sql
```
После, заходим обратно в контейнер и выводим настройки master сервера (они понадобятся при настройке slave сервера):
``` 
docker exec -it replication-master-ubuntu mysql
mysql> SHOW MASTER STATUS;
```
Запоминаем значения File и Position

mysql-bin.000001

735563
![Alt text](https://github.com/greeksergius/homework/blob/main/12-6-sql-rep1/2022-10-25_13-16-19.png)

Снимаем блокировку базы данных мастера репликации:
``` 
mysql> UNLOCK TABLES;
``` 
Master готов, переходим к slave. Копируем дамп бд с нашей главной машины в докер контейнер слейва:
``` 
docker cp /путьгдесохранилинанашеймашине/world.sql replication-slave-ubuntu:/tmp/world.sql
``` 
Переходим в mysql слейва. Создаем БД  world. Экспортируем скопированный дамп с нашей машины в /tmp/world.sql слейва
``` 
docker exec -it replication-slave-ubuntu mysql
mysql> CREATE DATABASE `world`;
docker exec -it replication-slave-ubuntu bash
mysql world < /tmp/world.sql
``` 
Далее редактируем mysql конфиг файл слейва 
``` 
docker exec -it replication-slave-ubuntu bash
nano /etc/mysql/my.cnf
``` 
Содержание конфиг файла слейва. Вставляем после секции [mysqld] :
``` 
log_bin = mysql-bin
server_id = 2
relay-log = /var/lib/mysql/mysql-relay-bin
relay-log-index = /var/lib/mysql/mysql-relay-bin.index
read_only = 1
``` 
![Alt text](https://github.com/greeksergius/homework/blob/main/12-6-sql-rep1/2022-10-25_13-29-23.png) 

Перезагружаем slave
``` 
docker restart replication-slave-ubuntu
``` 
Настройка компонентов

Следующим шагом требуется прописать в базе данных на сервер slave, кто является master репликации и данные полученные в File и Position:
``` 
docker exec -it replication-slave-ubuntu mysql
mysql> CHANGE MASTER TO MASTER_HOST='replication-master-ubuntu',
MASTER_USER='replication', MASTER_LOG_FILE='mysql-bin.000001',
MASTER_LOG_POS=735563;
``` 
Далее запускаем журнал ретрансляции, и проверим статус операций на слейве:

``` 
mysql> START SLAVE;
mysql> SHOW SLAVE STATUS\G
``` 
![Alt text](https://github.com/greeksergius/homework/blob/main/12-6-sql-rep1/2022-10-25_12-19-35.png) 
## Тестирование режима работы 

Меняем данные на Server-Master:
``` 
docker exec -it replication-master-ubuntu mysql
mysql> USE world;
mysql> INSERT INTO city (Name, CountryCode, District, Population) VALUES ('Test-Replication-YAKUTIA', 'ALB', 'TOYON', 42);
``` 
Переходим на слейв и смотрим реплецировался ли запрос с мастера
``` 
docker exec -it replication-slave-ubuntu mysql
mysql> USE world;
mysql> SELECT * FROM city ORDER BY ID DESC LIMIT 1;
``` 
![Alt text](https://github.com/greeksergius/homework/blob/main/12-6-sql-rep1/2022-10-25_12-29-11.png) 

---

## Дополнительные задания (со звездочкой*)

Эти задания дополнительные (не обязательные к выполнению) и никак не повлияют на получение вами зачета по этому домашнему заданию. Вы можете их выполнить, если хотите глубже и/или шире разобраться в материале.

---

### Задание 3*. 

Выполните конфигурацию Master-Master репликации. Произведите проверку.

*Приложите скриншоты конфигурации, выполнения работы (состояния и режимы работы серверов).*

``` 

#### ОТВЕТ

Создаем два контейнера мастера  one и two
``` 
docker run -d --name replication-master-one -e MYSQL_ALLOW_EMPTY_PASSWORD=true -v ~/path/to/world/dump:/docker-entrypoint-initdb.d ubuntu/mysql
docker run -d --name replication-master-two -e MYSQL_ALLOW_EMPTY_PASSWORD=true -v ~/path/to/world/dump:/docker-entrypoint-initdb.d ubuntu/mysql
``` 
Прописываем в конфигах mysql id сервера (каждый на своем)
``` 
docker exec -it replication-master-one bash
nano /etc/mysql/my.cnf

server_id = 1
log_bin = mysql-bin #на первом
``` 
``` 
docker exec -it replication-master-two bash
nano /etc/mysql/my.cnf
server_id = 2
log_bin = mysql-bin #на втором
``` 
Создаем для них сеть и мост
``` 
docker network create replication 3
docker network connect replication3 replication-master-one
docker network connect replication3 replication-master-two
``` 
Перезагружаем добро, после внесения конфигов
``` 
docker restart replication-master-one
docker restart replication-master-two
``` 

Важно добавить пользователей на обоих серверах в mysql:
Пользователь: replication5
Пароль: Repli11Pass!!!
``` 
CREATE USER 'replication5'@'%' IDENTIFIED WITH mysql_native_password BY 'Repli11Pass!!!';
GRANT REPLICATION SLAVE ON *.* TO 'replication5'@'%';
ALTER USER 'replication5'@'%' IDENTIFIED WITH mysql_native_password BY 'Repli11Pass!!!';
``` 

На первом мастере указываем мастером второго
``` 
SLAVE STOP;
CHANGE MASTER TO MASTER_HOST = 'replication-master-two', MASTER_USER = 'replication5', MASTER_PASSWORD = 'Repli11Pass!!!', MASTER_LOG_FILE = 'mysql-bin.000009', MASTER_LOG_POS = 505;
SLAVE START;
``` 
На втором мастере указываем мастера первого
``` 
SLAVE STOP;
CHANGE MASTER TO MASTER_HOST = 'replication-master-one', MASTER_USER = 'replication5', MASTER_PASSWORD = 'Repli11Pass!!!', MASTER_LOG_FILE = 'mysql-bin.000009', MASTER_LOG_POS = 505;
SLAVE START;
``` 
Заходим в терминал первого мастера, заходим в mysql
``` 
create database example;
``` 
Создаем таблицу в бд example
``` 
CREATE TABLE tk2 (col1 INT, col2 CHAR(5), col3 DATE)
    PARTITION BY LINEAR KEY(col3)
    PARTITIONS 5;
 ``` 
Проверяем репликацию на втором и изменения в БД 
``` 
mysql> SHOW SLAVE STATUS\G
``` 
![Alt text](https://github.com/greeksergius/homework/blob/main/12-6-sql-rep1/2022-10-25_17-13-27.png) 


Инструкции:

https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04-ru

