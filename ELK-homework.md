# Домашнее задание к занятию 11.3 "ELK"
# Выполнил: Григорьев Сергей
____
 

Перед тем как выслать ссылку, убедитесь, что ее содержимое не является приватным (открыто на просмотр всем, у кого есть ссылка). Если необходимо прикрепить дополнительные ссылки, просто добавьте их в свой Google Docs.

Любые вопросы по решению задач задавайте в чате учебной группы.

## Задание 1. Elasticsearch.

> Установите и запустите elasticsearch, после чего поменяйте параметр cluster_name на случайный.

> Приведите скриншот команды 'curl -X GET 'localhost:9200/_cluster/health?pretty', сделанной на сервере с установленным elasticsearch. Где будет виден нестандартный cluster_name

![Alt text](https://github.com/greeksergius/homework/blob/main/ELK/2022-09-29_13-01-31.png)
**В дефолтном конфиге elasticsearch.yml изменены следующие параметры:**

cluster.name: E-grigsergey
 
 #node.name: node-1
 
 #node.roles: [ master,data ]
 
 #http.port: 9200

 network.host: 0.0.0.0
 
 discovery.seed_hosts: ["127.0.0.1", "[::1]"]

[elasticsearch.yml](https://github.com/greeksergius/homework/blob/main/ELK/elasticsearch.yml)

## Задание 2. Kibana.

> Установите и запустите kibana.

> Приведите скриншот интерфейса kibana на странице http://<ip вашего сервера>:5601/app/dev_tools#/console, где будет выполнен запрос GET /_cluster/health?pretty

![Alt text](https://github.com/greeksergius/homework/blob/main/ELK/2022-09-29_13-45-50.png)


**В дефолтном конфиге kibana.yml изменен только следующий параметр:**

server.port: 5601

server.host: "0.0.0.0"

elasticsearch.hosts: ["http://localhost:9200"]

[kibana.yml](https://github.com/greeksergius/homework/blob/main/ELK/kibana.yml)


## Задание 3. Logstash.

> Установить и запустить Logstash и Nginx. С помощью Logstash отправить access-лог nginx в Elasticsearch.
> Приведите скриншот интерфейса kibana, на котором видны логи nginx.

![Alt text](https://github.com/greeksergius/homework/blob/main/ELK/2022-10-01_10-27-34.png)

[logstash.yml](https://github.com/greeksergius/homework/blob/main/ELK/logstash.yml)

## Задание 4. Filebeat.

> Установить и запустить Filebeat. Переключить поставку логов Nginx с Logstash на Filebeat.

> Приведите скриншот интерфейса kibana, на котором видны логи nginx, которые были отправлены через Filebeat.


![Alt text](https://github.com/greeksergius/homework/blob/main/ELK/2022-10-05_13-39-01.png)

[filebeat.yml](https://github.com/greeksergius/homework/blob/main/ELK/filebeat.yml)

Настройки в активированном модуле filebeat NGINX

[nginx.yml](https://github.com/greeksergius/homework/blob/main/ELK/nginx.yml)

------
Дополнительные задания (со звездочкой*). Эти задания дополнительные (не обязательные к выполнению) и никак не повлияют на получение вами зачета по этому домашнему заданию. Вы можете их выполнить, если хотите глубже и/или шире разобраться в материале.

## Задание 5*. Доставка данных.

Настройте поставку лога в Elasticsearch через Logstash и Filebeat любого другого сервиса(не nginx). Для этого лог должен писаться на файловую систему, Logstash должен корректно его распарсить и разложить на поля.

Приведите скриншот интерфейса kibana, на котором будет виден этот лог и напишите лог какого приложения отправляется.
