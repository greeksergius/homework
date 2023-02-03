# Дипломный проект по профессии "Системный администратор"
# Выполнил: Сергей Григорьев, группа SYS-10
# Задание:
Содержание
==========
* [Задача](#Задача)
* [Инфраструктура](#Инфраструктура)
    * [Сайт](#Сайт)
    * [Мониторинг](#Мониторинг)
    * [Логи](#Логи)
    * [Сеть](#Сеть)
    * [Резервное копирование](#Резервное-копирование)
    * [Дополнительно](#Дополнительно)
* [Выполнение работы](#Выполнение-работы)
* [Критерии сдачи](#Критерии-сдачи)
* [Как правильно задавать вопросы дипломному руководителю?](#Как-правильно-задавать-вопросы-дипломному-руководителю?) 

---------
## Задача
Ключевая задача - разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в [Yandex Cloud](https://cloud.yandex.com/).

## Инфраструктура
Для развертки инфраструктуры используйте Terraform и Ansible. 

Параметры виртуальной машины (ВМ) подбирайте по потребностям сервисов, которые будут на ней работать. 

Пожалуйста, ознакомьтесь со всеми пунктами из этой секции, не беритесь сразу выполнять задание, не дочитав до конца. Пункты тут взаимосвязаны и могут влиять друг на друга.
### Сайт
Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши web-сервера.

Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.

Создайте [Target Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/target-group), включите в нее две созданных ВМ.

Создайте [Backend Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/backend-group), настройте backends на target group ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP

Создайте [HTTP router](https://cloud.yandex.com/docs/application-load-balancer/concepts/http-router). Путь укажите - /, backend group - созданную ранее.

Создайте [Application load balancer](https://cloud.yandex.com/en/docs/application-load-balancer/) для распределения трафика на web-сервера, созданные ранее. Укажите HTTP router созданный ранее, задайте listener тип auto, порт 80.

Протестируйте сайт
`curl -v <публичный IP балансера>:80` 
### Мониторинг
Создайте ВМ, разверните на ней Prometheus. На каждую ВМ из web серверов установите Node Exporter и [Nginx Log Exporter](https://github.com/martin-helmich/prometheus-nginxlog-exporter). Настройте Prometheus на сбор метрик с этих exporter.

Создайте ВМ, установите туда Grafana. Настройте ее на взаимодейтсвие с ранее развернутым Prometheus. Настройте дешборды с отображением метрик, минимальный набор - Utilization, Saturation, Errors для CPU, RAM, диски, сеть, http_response_count_total, http_response_size_bytes. Добавьте необходимые [tresholds](https://grafana.com/docs/grafana/latest/panels/thresholds/) на соответствующие графики.
### Логи
Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к web-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.

Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.
### Сеть
Разверните один VPC. Сервера web, Prometheus, Elasticsearch поместите в приватные подсети. Сервера Grafana, Kibana, application load balancer определите в публичную подсеть.

Настройте [Security Groups](https://cloud.yandex.com/docs/vpc/concepts/security-groups) соответствующих сервисов на входящий трафик только к нужным портам.

Настройте ВМ с публичным адресом, в которой будет открыт только один порт - ssh. Настройте все security groups на разрешение входящего ssh из этой security group. Эта вм будет реализовывать концепцию bastion host. Потом можно будет подключаться по ssh ко всем хостам через этот хост.
### Резервное копирование
Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.
### Дополнительно
Не входит в минимальные требования. 
- Для Prometheus можно реализовать альтернативный способ хранения данных - в базе данных PpostgreSQL. Используйте [Yandex Managed Service for PostgreSQL](https://cloud.yandex.com/en-ru/services/managed-postgresql). Разверните кластер из двух нод с автоматическим failover. Воспользуйтесь адаптером с https://github.com/CrunchyData/postgresql-prometheus-adapter для настройки отправки данных из Prometheus в новую БД
- Вместо конкретных ВМ, которые входят в target group можно создать [Instance Group](https://cloud.yandex.com/en/docs/compute/concepts/instance-groups/), для которой настройте следующие правила автоматического горизонтального масштабирования: минимальное количество ВМ на зону - 1, максимальный размер группы - 3.
- Можно добавить в Grafana оповещения с помощью Grafana alerts. Как вариант, можно также установить Alertmanager в ВМ к Prometheus, настроить оповещения через него.
- В Elasticsearch добавьте мониторинг логов самого себя, Kibana, Prometheus, Grafana через filebeat. Можно использовать logstash тоже.
- Воспользуйтесь Yandex Certificate Manager, выпустите сертификат для сайта, если есть доменное имя. Перенастройте работу балансера на HTTPS, при этом нацелен он будет на HTTP web серверов.
- 
#  Пояснительная записка по дипломному проекту по профессии "Системный администратор"

## Инфраструктура
Для развертки инфраструктуры используйте Terraform и Ansible. 

## Ссылка на проект с terraform манифестами и ролями ansible в формате zip - [скачать](http://81.177.165.178/clouddiplom.zip)

Для удобства работы и интерпритации информации, план инфраструктуры поделен на 5 манифестов terraform:

`1. main.tf` - основной манифест, в нем инициализируется провайдер Yandex.Сloud. Так как токен является важным элементом безопасности инфраструктуры, он задается в объявленной переменной var.tokenvar. Далее в данном файле описывается конфигурация необходимых виртуальных машин (два веб-сервера nginx, kibana, elasticsearch, grafana, prometheus, bastion), создание резервного копирования дисков ВМ. В нем попробовал применить циклы для создания двух ВМ веб-серверов.

`2. variable.tf` - манифест переменных -  при изучении различных материалов по terraform часто рекомендовалось применять переменные, для более быстрого изменения данных во всем плане инфраструктуры, которые могут быть часто подвергнуты изменениям, как например, ip-адреса, количества ядер, индентификаторы образов и т.д.

`3. netsettings.tf` - сюда вынесено описание сетевой инфраструктуры проекта.

`4. ansibleinventory.tf` - описываются  ИП-адреса необходимых ВМ для создания инвентарного файла используемого для ansible

`5. outputs.tf` - описание выдаваемых результатов. Это внешний адрес балансировщика для просмотра веб-сайта и адрес бастиона для подключения по ssh.

В корне проекта содержится директория `ansiblefiles`, где расположены роли плейбуков ansible, файлы конфигураций сервисов, файлы для загрузки (веб-сайт, дашборды), инвентарьный файл ansible, который создается terraform`ом после раскатки инфраструктуры в облако. 

В директории `ansiblefiles` расположены следующие плейбуки с ролями:

`1_nginx` - (без роли) для установки вебс-сервера nginx, копирования файла конфигурации и копирования файлов веб-сайта на сервер.

`2_prometheus` - за основу взята роль от cloudalchemy ([cloudalchemy.prometheus](https://github.com/cloudalchemy/ansible-prometheus))

`3_nginxlog-exporter` - за основу взята роль от mbaran0v ([mbaran0v.prometheus-nginxlog-exporter](https://github.com/mbaran0v/ansible-role-prometheus-nginxlog-exporter))

`4_node-exporter` - за основу взята роль от cloudalchemy ([cloudalchemy.node_exporter](https://github.com/greeksergius/ansible-node-exporter))

`5_elastic` - за основу взята роль от geerlingguy ([geerlingguy.elasticsearch](https://github.com/geerlingguy/ansible-role-elasticsearch))

`6_filebeat` - за основу взята роль от geerlingguy ([geerlingguy.filebeat](https://github.com/geerlingguy/ansible-role-filebeat))

`7_kibana` - за основу взята роль от geerlingguy ([geerlingguy.kibana](https://github.com/geerlingguy/ansible-role-kibana))

`6_filebeat` - за основу взята роль от geerlingguy ([geerlingguy.filebeat](https://github.com/geerlingguy/ansible-role-filebeat))

`8_grafana` - за основу взята роль от cloudalchemy ([cloudalchemy.grafana](https://github.com/cloudalchemy/ansible-grafana)) и  
([39-PE-monitoring-dashboard](https://gitlab.com/xavki/devopsland/-/tree/master/ansible/39-PE-monitoring-dashboard/ansible_dir)) 

### В связи с санкциями и прочим нехорошим поведением народонаселения планеты, ресурсы ELK закрыты пользователям из РФ, использование TOR давало эффект установки раз через раз, установки некоторых пакетов тоже иногда капризничали, поэтому было принято решение разместить их на своем рабочем веб-сервере, что позволило предостерчься  от нескольких прядей  седых волос на голове.


## Сайт
Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши web-сервера.

Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.

[Адрес веб-сайта](http://84.201.157.97/)

![Alt-текст](https://github.com/greeksergius/homework/blob/main/sys-diplom/img/scrnwebsite.png)

Создайте [Target Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/target-group), включите в нее две созданных ВМ.

![Alt-текст](https://github.com/greeksergius/homework/blob/main/sys-diplom/img/targetgroup.png)

Создайте [Backend Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/backend-group), настройте backends на target group ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP

![Alt-текст](https://github.com/greeksergius/homework/blob/main/sys-diplom/img/backend.png)

Создайте [HTTP router](https://cloud.yandex.com/docs/application-load-balancer/concepts/http-router). Путь укажите - /, backend group - созданную ранее.

![Alt-текст](https://github.com/greeksergius/homework/blob/main/sys-diplom/img/httrouter.png)

![Alt-текст](https://github.com/greeksergius/homework/blob/main/sys-diplom/img/myyavpc.png)

Создайте [Application load balancer](https://cloud.yandex.com/en/docs/application-load-balancer/) для распределения трафика на web-сервера, созданные ранее. Укажите HTTP router созданный ранее, задайте listener тип auto, порт 80.

![Alt-текст](https://github.com/greeksergius/homework/blob/main/sys-diplom/img/loadbalancer.png)

Протестируйте сайт
`curl -v <публичный IP балансера>:80` 

![Alt-текст](https://github.com/greeksergius/homework/blob/main/sys-diplom/img/curlwebsite.png)

## Мониторинг
Создайте ВМ, разверните на ней Prometheus. На каждую ВМ из web серверов установите Node Exporter и [Nginx Log Exporter](https://github.com/martin-helmich/prometheus-nginxlog-exporter). Настройте Prometheus на сбор метрик с этих exporter.

Создайте ВМ, установите туда Grafana. Настройте ее на взаимодейтсвие с ранее развернутым Prometheus. Настройте дешборды с отображением метрик, минимальный набор - Utilization, Saturation, Errors для CPU, RAM, диски, сеть, http_response_count_total, http_response_size_bytes. Добавьте необходимые [tresholds] на соответствующие графики.
(https://grafana.com/docs/grafana/latest/panels/thresholds/) 

### За основу были взяты дашборды:

### [NGINX exporter](https://grafana.com/grafana/dashboards/12708-nginx/)

### и

### [Node Exporter Full](https://grafana.com/grafana/dashboards/1860-node-exporter-full/) 

### Добавлены Utilization, Saturation для CPU.

### Настраиваем дашборды и пороговые значения для них. 

![Alt-текст](https://github.com/greeksergius/homework/blob/main/sys-diplom/img/nodeexporterfull.png)

![Alt-текст](https://github.com/greeksergius/homework/blob/main/sys-diplom/img/grafana%20response.png)

![Alt-текст](https://github.com/greeksergius/homework/blob/main/sys-diplom/img/Nginx%20log%20exporter.png)

![Alt-текст](https://github.com/greeksergius/homework/blob/main/sys-diplom/img/nodeexporter3days.png)

![Alt-текст](https://github.com/greeksergius/homework/blob/main/sys-diplom/img/node%20exporter%20one.png)

### Видим загруженные плейбуком дашборды

![Alt-текст](https://github.com/greeksergius/homework/blob/main/sys-diplom/img/grafanadashexport.png)

![Alt-текст](https://github.com/greeksergius/homework/blob/main/sys-diplom/img/grafana%20dashdir.png)


### Редактируем JSON файл (заменял uid datasource, т.к. после повторного разворачивания ВМ ид прометея был другой и нужно было поправлять графики), для последующего импорта с помощью плейбука ansible
![Alt-текст](https://github.com/greeksergius/homework/blob/main/sys-diplom/img/editjson.png)

## Логи
Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к web-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.

Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.

### На скриншоте Kibana видим, что filebeat видит логи nginx  на веб-серверах и отправляет их в Elasticsearch

![Alt-текст](https://github.com/greeksergius/homework/blob/main/sys-diplom/img/ELK%20filebeat.png)

## Сеть
Разверните один VPC. Сервера web, Prometheus, Elasticsearch поместите в приватные подсети. Сервера Grafana, Kibana, application load balancer определите в публичную подсеть.

![Alt-текст](https://github.com/greeksergius/homework/blob/main/sys-diplom/img/myyavpc.png)

Настройте [Security Groups](https://cloud.yandex.com/docs/vpc/concepts/security-groups) соответствующих сервисов на входящий трафик только к нужным портам.

Пример настройки портов у приложения Kibana:

![Alt-текст](https://github.com/greeksergius/homework/blob/main/sys-diplom/img/secpublic.png)

Настройте ВМ с публичным адресом, в которой будет открыт только один порт - ssh. Настройте все security groups на разрешение входящего ssh из этой security group. Эта вм будет реализовывать концепцию bastion host. Потом можно будет подключаться по ssh ко всем хостам через этот хост.

![Alt-текст](https://github.com/greeksergius/homework/blob/main/sys-diplom/img/bastionssh.png)


## Резервное копирование
Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.

Настройки создания снэпшотов дисков задаются в манифесте  `main.tf` (в самом конце). В настройки переменных передаем индентификатары дисков инстансов полученные после публикации инфраструктуры в облаке.

![Alt-текст](https://github.com/greeksergius/homework/blob/main/sys-diplom/img/snapshotbackups.png)


![Alt-текст](https://github.com/greeksergius/homework/blob/main/sys-diplom/img/snapshotbackupslist.png)

1 диска ВМ здесь нет, т.к. я тестировал nginx и балансировщик и id диска уже у одной машины изменился.
![Alt-текст](https://github.com/greeksergius/homework/blob/main/sys-diplom/img/snapshotcomplite.png)

