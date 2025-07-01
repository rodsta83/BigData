# Тестирование установки RPM-пакетов Ambari 3.0 в среде Docker

Это руководство поможет настроить Docker-окружение для разработки и тестирования Apache Ambari. 
Использование контейнеров Docker предоставляет легковесную альтернативу виртуальным машинам при сохранении возможности создания многоконтурной среды.


## Предварительные требования

Убедитесь, что установлено:

  * Docker Engine (версия 20.10.0 или новее)  
  * Docker Compose (версия 2.0.0 или новее)  
  * Минимум 8 ГБ свободной ОЗУ (для кластера из 4 узлов)  
  * Минимум 20 ГБ свободного места на диске

## Обзор окружения

  * 1 контейнер (bigtop_hostname0) для Ambari Server  
  * 3 контейнера (bigtop_hostname1-3) для Ambari Agents  
  * Общий том для репозитория Ambari  
  * Образ bigtop/puppet:trunk-rockylinux-8 с предустановленными зависимостями  

## Создание Docker Compose файла

На предыдущем шаге мы подготовили RPM репозиторий в этой папке: /var/www/html/ambari_repo/ambari-3.0
Укажим ее в volumes каждого сервиса:

```shell
version: '3'

services:
  bigtop_hostname0:
    command: /sbin/init
    domainname: bigtop.apache.org
    image: bigtop/puppet:trunk-rockylinux-8
    mem_limit: 8g
    mem_swappiness: 0
    ports:
      - "8080:8080"
    privileged: true
    volumes:
      - ./var/www/html/ambari_repo/ambari-3.0:/var/repo/ambari

  bigtop_hostname1:
    command: /sbin/init
    domainname: bigtop.apache.org
    image: bigtop/puppet:trunk-rockylinux-8
    mem_limit: 8g
    mem_swappiness: 0
    privileged: true
    volumes:
      - ./var/www/html/ambari_repo/ambari-3.0:/var/repo/ambari

  bigtop_hostname2:
    command: /sbin/init
    domainname: bigtop.apache.org
    image: bigtop/puppet:trunk-rockylinux-8
    mem_limit: 8g
    mem_swappiness: 0
    privileged: true
    volumes:
      - ./var/www/html/ambari_repo/ambari-3.0:/var/repo/ambari

  bigtop_hostname3:
    command: /sbin/init
    domainname: bigtop.apache.org
    image: bigtop/puppet:trunk-rockylinux-8
    mem_limit: 8g
    mem_swappiness: 0
    privileged: true
    volumes:
      - ./var/www/html/ambari_repo/ambari-3.0:/var/repo/ambari

```

Эта конфигурация создает четыре контейнера:

```bigtop\_hostname0```: узел сервера Ambari с открытым портом 8080.

```bigtop\_hostname1, bigtop\_hostname2, bigtop\_hostname3```: узлы агентов Ambari.

Каждый контейнер использует образ ```bigtop/puppet:trunk-rockylinux-8```, предварительно настроенный с большинством зависимостей, необходимых для сервисов Ambari и Hadoop.

##  Настройка файла hosts

Создайте файл для разрешения имен:

Контейнеры должны иметь возможность обмениваться информацией друг с другом по именам хостов. Создайте файл hosts, который будет монтироваться в каждом контейнере:

```shell
mkdir -p conf
cat > conf/hosts << EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

# Container hostnames
172.20.0.2  bigtop_hostname0
172.20.0.3  bigtop_hostname1
172.20.0.4  bigtop_hostname2
172.20.0.5  bigtop_hostname3
EOF
```
Теперь обновите ваш файл docker-compose.yml, чтобы подключить этот файл hosts:

```shell
version: '3'

services:
  bigtop_hostname0:
    command: /sbin/init
    domainname: bigtop.apache.org
    image: bigtop/puppet:trunk-rockylinux-8
    mem_limit: 8g
    mem_swappiness: 0
    ports:
      - "8080:8080"
    privileged: true
    volumes:
      - ./var/www/html/ambari_repo/ambari-3.0:/var/repo/ambari
      - ./conf/hosts:/etc/hosts

  bigtop_hostname1:
    command: /sbin/init
    domainname: bigtop.apache.org
    image: bigtop/puppet:trunk-rockylinux-8
    mem_limit: 8g
    mem_swappiness: 0
    privileged: true
    volumes:
      - ./var/www/html/ambari_repo/ambari-3.0:/var/repo/ambari
      - ./conf/hosts:/etc/hosts

  bigtop_hostname2:
    command: /sbin/init
    domainname: bigtop.apache.org
    image: bigtop/puppet:trunk-rockylinux-8
    mem_limit: 8g
    mem_swappiness: 0
    privileged: true
    volumes:
      - ./var/www/html/ambari_repo/ambari-3.0:/var/repo/ambari
      - ./conf/hosts:/etc/hosts

  bigtop_hostname3:
    command: /sbin/init
    domainname: bigtop.apache.org
    image: bigtop/puppet:trunk-rockylinux-8
    mem_limit: 8g
    mem_swappiness: 0
    privileged: true
    volumes:
      - ./var/www/html/ambari_repo/ambari-3.0:/var/repo/ambari
      - ./conf/hosts:/etc/hosts
```

## Понимание образа BigTop

Образ ```bigtop/puppet:trunk-rockylinux-8``` является частью проекта Apache BigTop, предоставляющего инфраструктуру для сборки и тестирования проектов, связанных с Hadoop. 
Этот образ включает в себя следующие компоненты:

- ```Rocky Linux 8``` в качестве базовой операционной системы;
- Предустановленные Java и инструменты разработки;
- Puppet для управления конфигурациями;
- Оптимизированные системные настройки для служб экосистемы Hadoop.

Использование этого образа упрощает процесс установки, поскольку многие зависимости, необходимые для Ambari, уже установлены или сконфигурированы заранее.

## Запуск среды Docker

Запустите Docker-контейнеры следующей командой:

```shell
docker-compose up -d
```

Эта команда запускает контейнеры в фоновом режиме («детачед-моде»). 
Вы увидите вывод, подтверждающий создание контейнеров.

Проверка работоспособности окружения

Убедитесь, что все контейнеры запущены и правильно настроены:

## Проверьте статус контейнеров

```shell
docker ps
```

## Протестируйте сетевое соединение между контейнерами

```shell
docker exec -it bigtop_hostname0 ping -c 2 bigtop_hostname1
docker exec -it bigtop_hostname0 ping -c 2 bigtop_hostname2
docker exec -it bigtop_hostname0 ping -c 2 bigtop_hostname3
```

Эти команды проверяют доступность остальных узлов сети из узла ```bigtop_hostname0```.