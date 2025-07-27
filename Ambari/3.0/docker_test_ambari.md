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

```bigtop_hostname0```: узел сервера Ambari с открытым портом 8080.

```bigtop_hostname1, bigtop_hostname2, bigtop_hostname3```: узлы агентов Ambari.

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
##  Создаем обущую сеть docker

Чтобы все контейнеры были в одной сети:

```shell
docker network create --subnet=172.20.0.0/24 --gateway=172.20.0.1 bigtop-network
```

Теперь обновите ваш файл docker-compose.yml, чтобы подключить этот файл hosts и указать общую сеть docker с флагом external:

```shell
version: '3'

services:
  bigtop_hostname0:
    container_name: bigtop_hostname0
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
    networks:
      bigtop-network:
        ipv4_address: 172.20.0.2

  bigtop_hostname1:
    container_name: bigtop_hostname1
    command: /sbin/init
    domainname: bigtop.apache.org
    image: bigtop/puppet:trunk-rockylinux-8
    mem_limit: 8g
    mem_swappiness: 0
    privileged: true
    volumes:
      - ./var/www/html/ambari_repo/ambari-3.0:/var/repo/ambari
      - ./conf/hosts:/etc/hosts
    networks:
      bigtop-network:
        ipv4_address: 172.20.0.3

  bigtop_hostname2:
    container_name: bigtop_hostname2
    command: /sbin/init
    domainname: bigtop.apache.org
    image: bigtop/puppet:trunk-rockylinux-8
    mem_limit: 8g
    mem_swappiness: 0
    privileged: true
    volumes:
      - ./var/www/html/ambari_repo/ambari-3.0:/var/repo/ambari
      - ./conf/hosts:/etc/hosts
    networks:
      bigtop-network:
        ipv4_address: 172.20.0.4

  bigtop_hostname3:
    container_name: bigtop_hostname3
    command: /sbin/init
    domainname: bigtop.apache.org
    image: bigtop/puppet:trunk-rockylinux-8
    mem_limit: 8g
    mem_swappiness: 0
    privileged: true
    volumes:
      - ./var/www/html/ambari_repo/ambari-3.0:/var/repo/ambari
      - ./conf/hosts:/etc/hosts
    networks:
      bigtop-network:
        ipv4_address: 172.20.0.5

networks:
  bigtop-network:
    external: true
    name: bigtop-networkr
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

Открываем BASH консоль. Переходим в папку, где лежит файл ```docker-compose.yml```. Запустите Docker-контейнеры следующей командой:

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

Вы должны увидеть такой вывод запущенных контейнеров:

```
CONTAINER ID   IMAGE                              COMMAND        CREATED         STATUS         PORTS                                         NAMES
8e9ee43a47b9   bigtop/puppet:trunk-rockylinux-8   "/sbin/init"   7 minutes ago   Up 7 minutes                                                 bigtop_hostname2
acf765e18ad6   bigtop/puppet:trunk-rockylinux-8   "/sbin/init"   7 minutes ago   Up 7 minutes                                                 bigtop_hostname3
d93265df0a8e   bigtop/puppet:trunk-rockylinux-8   "/sbin/init"   7 minutes ago   Up 7 minutes   0.0.0.0:8080->8080/tcp, [::]:8080->8080/tcp   bigtop_hostname0
9e5512bb4eb3   bigtop/puppet:trunk-rockylinux-8   "/sbin/init"   7 minutes ago   Up 7 minutes                                                 bigtop_hostname1
```

## Установите необходимые пакеты на все контейнеры

Заходим в каждый контейнер командой ```docker exec -it bigtop_hostname0 bash``` и устанавливаем дополнительные зависимости ниже:

```shell
    # Установка базовых утилит
    dnf install -y sudo openssh-server openssh-clients which iproute net-tools less vim-enhanced
    # Установка инструментов разработки
    dnf install -y initscripts wget curl tar unzip git
    # Включение репозитория PowerTools
    dnf install -y dnf-plugins-core
    dnf config-manager --set-enabled powertools
    # Обновление системы
    dnf update -y
```

## Протестируйте сетевое соединение между контейнерами

```shell
docker exec -it bigtop_hostname0 ping -c 2 bigtop_hostname1
docker exec -it bigtop_hostname0 ping -c 2 bigtop_hostname2
docker exec -it bigtop_hostname0 ping -c 2 bigtop_hostname3
```

Эти команды проверяют доступность остальных узлов сети из узла ```bigtop_hostname0```.

Вывод пинга будет таким:

```shell
PING bigtop_hostname2 (172.20.0.4) 56(84) bytes of data.
64 bytes from bigtop_hostname2 (172.20.0.4): icmp_seq=1 ttl=64 time=0.136 ms
64 bytes from bigtop_hostname2 (172.20.0.4): icmp_seq=2 ttl=64 time=0.069 ms
```

## Настройка доступа по SSH между контейнерами и отключите SELinux и брэндмауер на всех контейнерах

Для этого подготовлен bash скрипт setup-ssh.sh , выполните его ```bash setup-ssh.sh```.

```shell
#!/bin/bash

# Setup SSH for all containers
docker exec -i bigtop_hostname0 bash << EOF
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
    setenforce 0
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    systemctl enable sshd
    systemctl start sshd
    exit
EOF

docker exec -i bigtop_hostname1 bash << EOF
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
    setenforce 0
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    systemctl enable sshd
    systemctl start sshd
    exit
EOF

docker exec -i bigtop_hostname2 bash << EOF
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
    setenforce 0
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    systemctl enable sshd
    systemctl start sshd
    exit
EOF

docker exec -i bigtop_hostname3 bash << EOF
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
    setenforce 0
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    systemctl enable sshd
    systemctl start sshd
    exit
EOF
```

## Скопировать SSH-ключ с сервера на агенты контейнеров bigtop_hostname1, bigtop_hostname2, bigtop_hostname3

```shell
# Извлекаем публичный ключ из контейнера bigtop_hostname0
docker exec bigtop_hostname0 cat /root/.ssh/id_rsa.pub > /tmp/host0_key.pub

# Копируем ключ в другие контейнеры
docker cp /tmp/host0_key.pub bigtop_hostname1:/tmp/host0_key.pub
docker cp /tmp/host0_key.pub bigtop_hostname2:/tmp/host0_key.pub
docker cp /tmp/host0_key.pub bigtop_hostname3:/tmp/host0_key.pub

# Добавляем ключ в authorized_keys каждого контейнера
docker exec bigtop_hostname1 bash -c 'cat /tmp/host0_key.pub >> /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys'
docker exec bigtop_hostname2 bash -c 'cat /tmp/host0_key.pub >> /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys'
docker exec bigtop_hostname3 bash -c 'cat /tmp/host0_key.pub >> /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys'
```

## Включите репозиторий разработки

Для установки зависимостей, необходимых для Ambari, необходимо включить репозиторий разработки Rocky Linux в каждом контейнере bigtop_hostname0, bigtop_hostname1, bigtop_hostname2, bigtop_hostname3:

```shell
docker exec -it bigtop_hostname0 bash
sed -i 's/^enabled=.*$/enabled=1/' /etc/yum.repos.d/Rocky-Devel.repo
```

Проверяем командой ```dnf repolist | grep devel```

Должны увидеть результат:

```
devel Rocky Linux 8 - Devel WARNING! FOR BUILDROOT AND KOJI USE
```