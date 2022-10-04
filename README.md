# homework
Домашнее задание к занятию 11.4 "Очереди RabbitMQ" 
Григорьев Сергей

Задание 1. Установка RabbitMQ
Используя Vagrant или VirtualBox, создайте виртуальную машину и установите RabbitMQ. Добавьте management plug-in и зайдите в веб интерфейс.
Итогом выполнения домашнего задания будет приложенный скриншот веб интерфейса RabbitMQ.
![Alt text](https://github.com/greeksergius/homework/blob/main/2022-10-03_17-51-42.png)

Задание 2. Отправка и получение сообщений.
Используя приложенные скрипты, проведите тестовую отправку и получение сообщения. Для отправки сообщений необходимо запустить скрипт producer.py
Для работы скриптов вам необходимо установить Python версии 3 и библиотеку pika. Также в скриптах нужно указать ip адрес машины, на которой запущен RabbitMQ, заменив localhost на нужный ip.
$ pip install pika
Зайдите в веб интерфейс, найдите очередь под названием hello и сделайте скриншот. После чего запустите второй скрипт consumer.py и сделайте скриншот результата выполнения скрипта
В качестве решения домашнего задания приложите оба скриншота, сделанных на этапе выполнения.
Для закрепления материала можете попробовать модифицировать скрипты, чтобы поменять название очереди и отправляемое сообщение.

Запуск скрипта  producer.py
![Alt text](https://github.com/greeksergius/homework/blob/main/2022-10-04_19-15-57.png)
Запуск скрипта  consumer.py 
![Alt text](https://github.com/greeksergius/homework/blob/main/2022-10-04_19-17-35.png)

Задание 3. Подготовка HA кластера
Используя Vagrant или VirtualBox, создайте вторую виртуальную машину и установите RabbitMQ. Добавьте в файл hosts название и ip адрес каждой машины, чтобы машины могли видеть друг друга по имени.
![Alt text](https://github.com/greeksergius/homework/blob/main/2022-10-04_19-22-24.png)

Также приложите вывод команды с двух нод:
$ rabbitmqctl cluster_status
Скриншот первой головной ноды
![Alt text](https://github.com/greeksergius/homework/blob/main/2022-10-04_19-26-56.png)
Скриншот второй ноды
![Alt text](https://github.com/greeksergius/homework/blob/main/2022-10-04_19-29-24.png)


![Alt text](https://github.com/greeksergius/homework/blob/main/2022-10-04_18-46-58.png)
