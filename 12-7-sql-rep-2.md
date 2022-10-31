# Домашнее задание к занятию 12.7 "Репликация и масштабирование. Часть 2"
# Выполнил: Григорьев Сергей.

---

### Задание 1.

Опишите основные преимущества использования масштабирования методами:

- активный master-сервер и пассивный репликационный slave-сервер, 
- master-сервер и несколько slave-серверов, 
- активный сервер со специальным механизмом репликации – distributed replicated block device (DRBD), 
- SAN-кластер.

---

## ОТВЕТ

Активный master-сервер и пассивный репликационный slave-сервер

Главный сервер называют мастером(master), а зависимые — репликами (slave). C английского Master&Slave переводится как «ведущий-ведомый», а репликацию (replecation) , как дублирование.  
Изменения данных, происходящие на мастере, повторяются на репликах (но не наоборот). Поэтому запросы на изменение данных (INSERT, UPDATE, DELETE и т. д.) выполняются только на мастере(master), а запросы на чтение данных (проще говоря, SELECT) могут выполняться как на репликах(slave) , так и на мастере(master). Процесс репликации на одной из реплик (slave) не влияет на работу других реплик(slave), и практически не влияет на работу мастера (master).

Цели и задачи использования данной схемы:
- производительность и масштабируемость. Один сервер может не справляться с нагрузкой, вызываемой одновременными операциями чтения и записи в БД. Выгода от создания реплик будет тем больше, чем больше операций чтения приходится на одну операцию записи в вашей системе.
- отказоустойчивость. В случае отказа реплики, все запросы чтения можно безопасно перевести на мастера. Если откажет мастер, запросы записи можно перевести на реплику (после того, как мастер будет восстановлен, он может принять на себя роль реплики).
- резервирование данных. Реплику можно «тормознуть» на время, чтобы выполнить mysqldump, а мастер — нет.
- отложенные вычисления. Тяжелые и медленные SQL-запросы можно выполнять на отдельной реплике, не боясь помешать нормальной работе всей системы.



> **- активный master-сервер и пассивный репликационный slave-сервер**

Используется для репликации данных при горизонтальном или вертикальном масштабировании, с целью наличия копии работопоспособной базы и в случае падения ведомой, а также перераспределении нагрузки  DML SQL запросов (INSERT, UPDATE, DELETE и т. д.) в ведущем Master и в ведомом (slave) DML SQL запросами (например, запросы на чтение из БД - SELECT). Данный метод позволяет хранить нам работоспособную копию базы данных и в случае порчи или падения ведущей, восстановиться или перейти с ней на ведомую, а так же снизить нагрузку на сервер, где расположен master, запросами выборки на slave. При горизонтальном  масштабировании, мы повышаем к тому же и отказоустойчивость от падений сервера при перегрузке или **-физическом выходе из строя**-, как это не получилось бы при использовании вертикальной репликации.


> **- master-сервер и несколько slave-серверов**

Используется чаще для репликации данных в горизонтальном масштабировании, как и в описанном выше варинте, но в качестве дополнения, в данной схеме чаще используется разноска таблиц (например при шардировании) и баз данных с ведущего master на разные ведомые slave. Например, на master есть базы данных  BD1 и BD2, соответственно репликация BD1 пойдет на slave 1, а BD2 на slave 2. Что позволить повысить высоконагруженность и отказоустойчивость проекта в целом, при работе с запросами и получением ответов с более быстрым результатом. 


> **- активный сервер со специальным механизмом репликации – distributed replicated block device (DRBD)**

DRBD (Distributed Replicated Block Device — распределённое реплицируемое блочное устройство) представляет собой распределенное, гибкое и универсально реплицируемое решение хранения данных для Linux. Оно отражает содержимое блочных устройств, таких как жесткие диски, разделы, логические тома и т.д. между серверами. Оно создает копии данных на двух устройствах хранения для того, чтобы в случае сбоя одного из них можно было использовать данные на втором.

Можно сказать, что это нечто вроде сетевой конфигурации RAID 1 с дисками, отражаемыми на разные сервера. Однако оно работает совсем не так, как RAID (даже сетевой).

Первоначально DRBD использовалось главным образом в компьютерных кластерах высокой доступности (HA — high availability), однако ныне оно может использоваться и для решений в облачном хранилище.

DRBD чрезвычайно гибок и универсален, что делает его решением для репликации хранилища, подходящим для добавления HA практически в любое приложение.

Поддерживает как синхронную, так и асинхронную репликацию (при синхронной, протокол «С», операция записи считается завершённой, когда и локальный, и удалённый диски сообщают об успешном завершении записи; при асинхронной, протокол «A», запись считается завершённой, когда запись завершилась на локальном устройстве и данные готовы к отправке на удалённый узел). Также поддерживается промежуточный протокол (B), при котором запись считается успешной, если она завершилась на локальное устройство, и удалённый узел подтвердил получение (но не локальную запись) данных[3]. Синхронизация идёт через протокол TCP (без шифрования и аутентификации), по умолчанию используется порт TCP/3260.

Поддерживает только два узла, более сложные конструкции могут строиться с помощью использования drbd-устройства в качестве «локального» для ещё одного drbd-устройства. 
**Пример:**
![Alt-текст](https://github.com/greeksergius/homework/blob/main/12-7-sql-rep-2/DRBD_concept_overview.png)


> **- SAN-кластер.**

Решение для повышения отказоустойчивости с более сетевым уклоном и доступности корпоративных информационных систем. Отказоустойчивость достигается за счет дублирования всех активных компонентов и встроенной системы мониторинга работоспособности.

В состав SAN кластера входит два и более узлов (серверов), каждый из которых конфигурируется таким образом, чтобы приложение (в нашем случае MySQL Server) могло работать на любом из них. При этом само приложение виртуализируется, т.е. становится независимым от какого-либо узла. Обязательным условием является наличие общей для всех узлов системы хранения. Основное приложение и все необходимые для его работы ресурсы, такие как файловые ресурсы или сетевое подключение, определяются в общую кластерную группу. В случае недоступности одного из ресурсов кластерной группы управляющее приложение инициирует перевод работы основного приложения и всей кластерной группы на другой узел.

Преимущества использования:
Предотвращение сбоев. Главным преимуществом от установки серверов баз данных в кластер является исключение длительного простоя в работе приложений, вызванного всевозможными отказами аппаратных средств, которые весьма вероятны для современных серверов, сложность которых постоянно растёт. Часто совсем маленькая проблема в состоянии вывести операционную систему из строя на длительный срок, причём подобные отказы не нуждаются в тщательном расследовании или переустановке компонентов или даже всего сервера, но они бывают достаточно серьезны, чтобы приложение оказалось неработоспособным на недопустимое время. Кластер может помочь в предотвращении многих подобных проблем в работе приложений, поскольку ресурсы приложения могут быть быстро переброшены на другой узел кластера, и часто сделать это можно даже без потери клиентских подключений.
 
Сервисное обслуживание. В данной реализации, как и в некоторых других вариациях кластеризации можно остановить один из ведомых серверов (а точнее служб) и произвести обновление каких-либо компонентов. 

Модернизация. Нередко возникает необходимость увеличения производительности серверов. Это означает необходимость миграции и продолжительного простоя. При использовании кластера миграцию выполнить намного легче и с минимальным временем простоя. В кластер добавляется новый узел, выполняется установка всех необходимых обновлений. Затем с помощью процедуры перехода на резервный ресурс выполняется перенос сервера на новый узел, а старый исключается из кластера. Время простоя ограничивается временем перехода на резервный ресурс, т.е. лишь несколько минут, вместо нескольких часов или даже нескольких суток без использования кластера.

**Пример:**

![Alt-текст](https://github.com/greeksergius/homework/blob/main/12-7-sql-rep-2/starwind-virtual-san-4-node-scale-out-cluster-1.jpeg)

---

### Задание 2.


Разработайте план для выполнения горизонтального и вертикального шаринга базы данных. База данных состоит из трех таблиц: 

- пользователи, 
- книги, 
- магазины (столбцы произвольно). 

Опишите принципы построения системы и их разграничение или (и) разбивку между базами данных.

*Пришлите блок схему, где и что будет располагатся. Опишите, в каких режимах будут работать сервера.* 

---

## ОТВЕТ

ыыыы



## Дополнительные задания (со звездочкой*)

Эти задания дополнительные (не обязательные к выполнению) и никак не повлияют на получение вами зачета по этому домашнему заданию. Вы можете их выполнить, если хотите глубже и/или шире разобраться в материале.

---
### Задание 3*.

Выполните настройку выбранных методов шардинга из задания 2.

*Пришлите конфиг docker и sql скрипт с командами для базы данных*