# Домашнее задание к занятию 12.6 "Репликация и масштабирование. Часть 1"
# Выполнил: Григорьев Сергей.

---

### Задание 1.

На лекции рассматривались режимы репликации master-slave, master-master, опишите их различия.

*Ответить в свободной форме.*

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


---

## Дополнительные задания (со звездочкой*)

Эти задания дополнительные (не обязательные к выполнению) и никак не повлияют на получение вами зачета по этому домашнему заданию. Вы можете их выполнить, если хотите глубже и/или шире разобраться в материале.

---

### Задание 3*. 

Выполните конфигурацию Master-Master репликации. Произведите проверку.

*Приложите скриншоты конфигурации, выполнения работы (состояния и режимы работы серверов).*

Инструкции:

https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04-ru
