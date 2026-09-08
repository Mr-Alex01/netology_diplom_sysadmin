# Дипломная работа по профессии «Системный администратор»

---

## Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в Yandex Cloud и отвечать минимальным стандартам безопасности: запрещается выкладывать токен от облака в git.

---

## Выполнение работы

## Состав проекта

Проект разделён на 3 главных контейнера:  
1. Terraform - инфраструктура: сеть, alb, vm, security groups. снапшоты  
2. Ansible - плейбуки: nginx, zabbix server/agents, elasticsearch, kibana, filebeat  
3. Img - скрины из работы сервисов

---

## 1. Авторизация

В ТЗ упоминается запрет на публикацию в git токенов от облака. Я использую авторизацию через яндекс cloud CLI в windows (команда yc init и генерация временных iam-токенов через export yc_token), поэтому в файлах конфигурации .tf физически нет секретных паролей. Terraform подхватывает токен из операционной системы.

![1](https://github.com/Mr-Alex01/netology_diplom_sysadmin/blob/main/img/yc_token.jpg)

## 2. Сетевая инфраструктура и Безопасность (VPC)

* С помощью terraform была развёрнута виртуальная сеть VPC с делением на 3 подсети. Публичные зоны выделены под балансировщик, бастион, kibana и zabbix; приватные зоны изолированы для elasticsearch и веб-серверов.  
* Security Groups: настроена строгая сетевая фильтрация портов в Yandex Cloud. Трафик из интернета разрешён только на целевые веб-порты.  
* Bastion host: поднят jump-сервер (Бастион) в публичном контуре. Он является единственной точкой входа по 22 порту ssh во внутренний периметр сети яндекса.  
* NAT-шлюз: настроен облачный nat-gateway, обеспечивающий безопасный изолированный выход серверов приватного контура в интернет для скачивания пакетов и обновлений.

## 3. Сайт и балансировщик

* Созданы два веб-сервера в разных зонах доступности на базе os ubuntu 24.04.  
* С помощью ansible написана роль, которая автоматически разворачивает веб-сервер, настраивает конфигурацию и публикует статичную страницу моего сайта с ФИО и названием профессии.  
* Развёрнут application load balancer яндекса с настройкой target и backend-групп, а также HTTP-роутера. Настроен непрерывный healthcheck, распределяющий http-запросы отовсюду на живые внутренние веб-серверы.

## 4. Сбор логов (Elastic Stack)

* Через Docker-контейнер развёрнуто хранилище elasticsearch 8.11.1 в приватной подсети.  
* На веб-серверы установлены агенты filebeat, которые в реальном времени отслеживают файлы access.log и error.log от nginx и передают их по внутренней сети в elastic.  
* В публичной подсети развёрнут веб-интерфейс kibana 8.11.1. Настроен data view filebeat-* и создана рабочая панель мониторинга событий безопасности и посещений сайта.

## 5. Мониторинг инфраструктуры. Zabbix

* Развёрнут сервер Zabbix версии 7.0 LTS в связке с базой данных postgresql 14 внутри docker-контейнеров на публичной vm.  
* На все 6 виртуальных машин с помощью ansible автоматически установлены агенты zabbix-agent2.  
* Были настроены дашборды с графиками и триггерами simple triggers (отвечающего за treshold), визуализирующие параметры utilization, saturation и errors для CPU, оперативной памяти, дисков и сетевых интерфейсов. Настроен веб-сценарий контроля времени ответов и доступности nginx.

## 6. Снапшоты

* В Terraform описан ресурс yandex_compute_snapshot_schedule.  
* Настроено автоматическое создание снэпшотов для всех 6 виртуальных машин проекта ежедневно в 02:00 и ограничением времени жизни копий в 7 дней (168 часов). 

## 7. Работа ресурсов

`На базе, созданной vpc были созданы 3 подсети разных зон, 2 приватных, 1 публичная.`

![2](https://github.com/Mr-Alex01/netology_diplom_sysadmin/blob/main/img/subnet.jpg)

`Создано 5 групп безопасности`

![3](https://github.com/Mr-Alex01/netology_diplom_sysadmin/blob/main/img/security_group.jpg)

`Работа балансировщика`

![4](https://github.com/Mr-Alex01/netology_diplom_sysadmin/blob/main/img/balancer.jpg)

`Целевая группа`

![5](https://github.com/Mr-Alex01/netology_diplom_sysadmin/blob/main/img/target_group.jpg)

`Группа бэкендов`

![6](https://github.com/Mr-Alex01/netology_diplom_sysadmin/blob/main/img/backend_group.jpg)

`Роутеры`

![7](https://github.com/Mr-Alex01/netology_diplom_sysadmin/blob/main/img/routher.jpg)

`Карта балансировки`

![8](https://github.com/Mr-Alex01/netology_diplom_sysadmin/blob/main/img/balance_map.jpg)

`Через терраформ развёрнутая инфраструктура из 6 ВМ`

![9](https://github.com/Mr-Alex01/netology_diplom_sysadmin/blob/main/img/Cloud_VM.jpg)

`Карта моей инфраструктуры`

![10](https://github.com/Mr-Alex01/netology_diplom_sysadmin/blob/main/img/infrastructure_map.jpg)

`Проверка связи с хостами через ansible`

![11](https://github.com/Mr-Alex01/netology_diplom_sysadmin/blob/main/img/ansible_hosts.jpg)

`Разворачивание веб-серверов и копирование файлов сайта`

![12](https://github.com/Mr-Alex01/netology_diplom_sysadmin/blob/main/img/playbook_webservers.jpg)

`Работа сайта по адресу балансировщика через curl -v`

![13](https://github.com/Mr-Alex01/netology_diplom_sysadmin/blob/main/img/HTTP_200_OK.jpg)

`Работа моего сайта со статичной страницей`

![14](https://github.com/Mr-Alex01/netology_diplom_sysadmin/blob/main/img/http.jpg)

`Визуальное отображение логов эластика в кибане и работа самой кибаны с агентом filebeat`

![15](https://github.com/Mr-Alex01/netology_diplom_sysadmin/blob/main/img/kibana_log.jpg)

![16](https://github.com/Mr-Alex01/netology_diplom_sysadmin/blob/main/img/kibana_access_log.jpg)

`Работа Zabbix. Все хосты добавлены на мониторинг`

![17](https://github.com/Mr-Alex01/netology_diplom_sysadmin/blob/main/img/zabbix_hosts.jpg)

`Созданный дашборд мониторинга. В триггеры добавлены монитор CPU, Memory, Disk, Network, http-ответов и доступности веб-серверов, а также ошибки.`

![18](https://github.com/Mr-Alex01/netology_diplom_sysadmin/blob/main/img/zabbix_dashboards.jpg)

`Для создания слепков в расписании создано создание снапшотов каждые сутки в 02:00 со сроком хранения в 7 дней`

![19](https://github.com/Mr-Alex01/netology_diplom_sysadmin/blob/main/img/snapshot_vm.jpg)








