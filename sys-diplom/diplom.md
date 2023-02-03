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

## Ссылка на проект с terraform манифестами и ролями ansible в формате zip - [скачать](https://cloud.yandex.com/docs/application-load-balancer/concepts/target-group)

Для удобства работы и просмотра информации, план инфраструктуры поделен на 5 манифестов terraform:

`1. main.tf` - основной манифест, в нем инициализируется провайдер Yandex.Сloud. Так как токен является важным элементом безопасности инфраструктуры, он задается в объявленной переменной var.tokenvar. Далее в данном файле описывается конфигурация необходимых виртуальных машин (два веб-сервера nginx, kibana, elasticsearch, grafana, prometheus, bastion), создание резервного копирования дисков ВМ. В нем попробовал применить циклы для создания двух ВМ веб-серверов.

`2. variable.tf` - манифест переменных -  при изучении различных материалов по terraform часто рекомендовалось применять переменные, для более быстрого изменения данных во всем плане инфраструктуры, которые могут быть часто подвергнуты изменениям, как например, ip-адреса, количества ядер, индентификаторы образов и т.д.

`3. netsettings.tf` - сюда вынесено описание сетевой инфраструктуры проекта.

`4. ansibleinventory.tf` - описываются  ИП-адреса необходимых ВМ для создания инвентарного файла используемого для ansible

`5. outputs.tf` - описание выдаваемых результатов. Это внешний адрес балансировщика для просмотра веб-сайта и адрес бастиона для подключения по ssh.

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
