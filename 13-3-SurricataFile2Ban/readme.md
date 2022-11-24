# Домашнее задание к занятию 13.3 "Защита сети"
# Выполнил: Григорьев Сергей
 
------

### Подготовка к выполнению заданий

1. Подготовка "защищаемой" системы:

- Установите **Suricata**;
- Установите **Fail2Ban**.

2. Подготовка системы злоумышленника: установите **nmap** и **thc-hydra** либо скачайте и установите **Kali linux**.

Обе системы должны находится в одной подсети.

------

### Задание 1.

Проведите разведку системы и определите, какие сетевые службы запущены на "защищаемой" системе:

**sudo nmap -sA < ip-адрес >**

**sudo nmap -sT < ip-адрес >**

**sudo nmap -sS < ip-адрес >**

**sudo nmap -sV < ip-адрес >**

(По желанию можете поэкспериментировать с опциями: https://nmap.org/man/ru/man-briefoptions.html )


*В качестве ответа пришлите события, которые попали в логи Suricata и Fail2Ban, прокомментируйте результат.*


  ### ОТВЕТ НА ЗАДАНИЕ 1.

Подробную информации в основном выдала команда sudo nmap -sV, где указала запущенные службы и их версии.
```
sudo tail -f /var/log/suricata/fast.log
```
Suricata не реагировала (видимо не настроены правила срабатывания)

![Alt text](https://github.com/greeksergius/homework/blob/main/13-3-SurricataFile2Ban/nmap1.png) 
![Alt text](https://github.com/greeksergius/homework/blob/main/13-3-SurricataFile2Ban/Nmapservices.png) 


------

### Задание 2.

Проведите атаку на подбор пароля для службы SSH:

**hydra -L users.txt -P pass.txt < ip-адрес > ssh**

1. Настройка **hydra**: 
 
 - создайте два файла: **users.txt** и **pass.txt**;
 - в каждой строчке первого файла должны быть имена пользователей, второго - пароли (в нашем случае это могут быть случайные строки, но ради эксперимента можете добавить имя и пароль существующего пользователя).

Дополнительная информация по **hydra**: https://kali.tools/?p=1847

2. Включение защиты SSH для Fail2Ban:

-  Открыть файл /etc/fail2ban/jail.conf;
-  Найти секцию **ssh**;
-  Установить **enabled**  в **true**.

Дополнительная информация по **Fail2Ban**:https://putty.org.ru/articles/fail2ban-ssh.html


*В качестве ответа пришлите события, которые попали в логи Suricata и Fail2Ban, прокомментируйте результат*


  ### ОТВЕТ НА ЗАДАНИЕ 2.
Утилитой Hydra выполнили команду подбора логина и пароля к SSH
```
hydra -L users.txt -P pass.txt 192.168.0.2 ssh
```
Судя по логу на 15 раз file2ban заблокировал ip-адрес атакующей машины (192.168.0.10), после чего атакующая машина уже не смогла производить подключение по SSH
```
cat /var/log/fail2ban.log
```

![Alt text](https://github.com/greeksergius/homework/blob/main/13-3-SurricataFile2Ban/file2banHOST.png) 
![Alt text](https://github.com/greeksergius/homework/blob/main/13-3-SurricataFile2Ban/file2banKali.png) 