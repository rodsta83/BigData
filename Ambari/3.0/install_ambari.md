
Ambari Server хранит ВСЁ своё состояние и метаданные кластера в базе данных.
Это центральный репозиторий конфигураций, топологии, истории операций и пользователей.
Ниже инструкция, где рассмотрим установку на примере postgresql


## Установите PostgreSQL сервер

```shell
dnf install -y postgresql-server
dnf install -y postgresql
```

2. Инициализация БД

```shell
postgresql-setup --initdb
#Вывод
* Initializing database in '/var/lib/pgsql/data'
* Initialized, logs are in /var/lib/pgsql/initdb_postgresql.log
```

3. Запуск службы postgresql
```shell
systemctl enable postgresql
systemctl start postgresql
```

4. Проверка статуса сервиса postgresql, что запущено без ошибок

```shell
systemctl status postgresql
```

5. Конфигурирование PostgreSQL
Активируйте параметр listen_addresses = '*'. Это означает, что сервер PostgreSQL теперь будет прослушивать запросы на всех сетевых интерфейсах сервера, а не только локально (`localhost`). 
Это полезно, если вам нужно подключаться удалённо к вашему экземпляру PostgreSQL с другого компьютера или сети.
```shell
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /var/lib/pgsql/data/postgresql.conf
```

6. Добавьте правила аутентификации клиентов в файл pg\_hba.conf

```shell
cat >> /var/lib/pgsql/data/pg_hba.conf << EOF
host ambari ambari 0.0.0.0/0 md5
host hive hive 0.0.0.0/0 md5
host ranger ranger 0.0.0.0/0 md5
host rangerkms rangerkms 0.0.0.0/0 md5
EOF
```

7. Создайте пользователей и базы данных


```shell
# Делаем логин в систему под пользователем postgres
su - postgres
# Запускаем консоль psql
psql
# Выполняем команды

CREATE ROLE "ambari" LOGIN PASSWORD 'admin' NOINHERIT;
CREATE DATABASE ambari;
GRANT ALL PRIVILEGES ON DATABASE ambari TO ambari;

CREATE ROLE "hive" LOGIN PASSWORD 'hive' NOINHERIT;
CREATE DATABASE hive;
GRANT ALL PRIVILEGES ON DATABASE hive TO hive;

CREATE ROLE "ranger" LOGIN PASSWORD 'ranger' NOINHERIT;
CREATE DATABASE ranger;
GRANT ALL PRIVILEGES ON DATABASE ranger TO ranger;

CREATE ROLE "rangerkms" LOGIN PASSWORD 'rangerkms' NOINHERIT;
CREATE DATABASE rangerkms;
GRANT ALL PRIVILEGES ON DATABASE rangerkms TO rangerkms;

#Создаем суперюзера
CREATE ROLE root WITH LOGIN SUPERUSER PASSWORD 'root';
```

Вывести список баз для проверки:
```shell
postgres=# \l
List of databases
Name    |  Owner   | Encoding | Collate |  Ctype  |   Access privileges
-----------+----------+----------+---------+---------+------------------------
ambari    | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =Tc/postgres          +
|          |          |         |         | postgres=CTc/postgres +
|          |          |         |         | ambari=CTc/postgres
hive      | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =Tc/postgres          +
|          |          |         |         | postgres=CTc/postgres +
|          |          |         |         | hive=CTc/postgres
postgres  | postgres | UTF8     | C.UTF-8 | C.UTF-8 |
ranger    | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =Tc/postgres          +
|          |          |         |         | postgres=CTc/postgres +
|          |          |         |         | ranger=CTc/postgres
rangerkms | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =Tc/postgres          +
|          |          |         |         | postgres=CTc/postgres +
|          |          |         |         | rangerkms=CTc/postgres
template0 | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres           +
|          |          |         |         | postgres=CTc/postgres
template1 | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres           +
|          |          |         |         | postgres=CTc/postgres
(7 rows)
```

8. Сделать замену ident на md5
```shell
    sed -i 's/ident$/md5/' /var/lib/pgsql/data/pg_hba.conf
```
9. Перезапустите PostgreSQL

```shell
    systemctl restart postgresql
```

## Подключаем репозиторий RPM

1. Включите репозиторий разработки

Для установки зависимостей, необходимых для Ambari, необходимо включить репозиторий разработки Rocky Linux:

```shell
sed -i 's/^enabled=.*$/enabled=1/' /etc/yum.repos.d/Rocky-Devel.repo
```

Проверяем командой ```dnf repolist | grep devel```

Должны увидеть результат:

```
Rocky Linux 9 - Devel WARNING! FOR BUILDROOT ONLY DO NOT LEAVE ENABLED
```

2. Создаем конфигурационный файл *.repo с описанием репозитория

```shell
cat > /etc/yum.repos.d/ambari_repo.repo << EOF
[ambari_repo]
name = Apache Ambari and Bigtop Repository
baseurl = http://ambari-3-builder/
enabled = 1
gpgcheck = 0
EOF
```
3. Проверьте работу репозитория:

```shell
# Обновить кэш
yum clean all
#вывод: 35 files removed
yum makecache
#Вывод:
#Apache Ambari and Bigtop Repository                                                                                                                                                                          5.4 MB/s | 289 kB     00:00
#Rocky Linux 9 - BaseOS                                                                                                                                                                                       4.7 MB/s | 2.5 MB     00:00
#Rocky Linux 9 - AppStream                                                                                                                                                                                    4.6 MB/s | 9.5 MB     00:02
#Rocky Linux 9 - CRB                                                                                                                                                                                          2.9 MB/s | 2.8 MB     00:00
#Rocky Linux 9 - Extras                                                                                                                                                                                       581  B/s |  17 kB     00:30
#Metadata cache created.
```

4. Посмотреть все пакеты в репозитории ambari_repo

```shell
yum --disablerepo="*" --enablerepo="ambari_repo" list available
```

5. Или поискать конкретные пакеты

```shell
yum --disablerepo="*" --enablerepo="ambari_repo" search ambari
yum --disablerepo="*" --enablerepo="ambari_repo" search hadoop
```

6. Установите следующие пакеты на всех хостах:

```shell
# Установите необходимые зависимости.
yum install -y python3-distro
yum install -y java-17-openjdk-devel
yum install -y java-1.8.0-openjdk-devel
yum install -y ambari-agent
```

## Установка Ambari server 

1. Установка  Ambari Server на назначенной машине сервера Ambari:
```shell
yum install -y python3-psycopg2
yum install -y ambari-server
```

2. Войти под su postgres и выполнить команду:
```shell
su postgres

PGPASSWORD='admin' psql -h localhost -p 5432 -U ambari -d ambari \
-f /var/lib/ambari-server/resources/Ambari-DDL-Postgres-CREATE.sql
```

3. Проверить выполнение скрипта:
```shell
su - postgres
psql -d ambari -c "\dt"
#Должны отобразиться таблицы Ambari.
```
4. Задать hostname ambari-server в конфиге ambari-agent
```shell
sed -i "s/hostname=.*/hostname=master-test1.lab.local/" /etc/ambari-agent/conf/ambari-agent.ini
```
5. Конфигурирование Ambari Server под PostgreSQL:

```shell
ambari-server setup --jdbc-db=postgres --jdbc-driver=/usr/lib/ambari-server/postgresql-42.3.8.jar

#Вывод:

#Using python  /usr/bin/python3
#Setup ambari-server
#Copying /usr/lib/ambari-server/postgresql-42.3.8.jar to /var/lib/ambari-server/resources/postgresql-42.3.8.jar
#Creating symlink /var/lib/ambari-server/resources/postgresql-42.3.8.jar to /var/lib/ambari-server/resources/postgresql-jdbc.jar
#If you are updating existing jdbc driver jar for postgres with postgresql-42.3.8.jar. Please remove the old driver jar, from all hosts. Restarting services that need the driver, will automatically copy the new jar to the hosts.
#JDBC driver was successfully initialized.
#Ambari Server 'setup' completed successfully.
```

Расшифровка вывода:
Выполнены шаги установки драйвера JDBC PostgreSQL для сервера Ambari:

1. Скопирован файл postgresql-42.3.8.jar из /usr/lib/ambari-server в каталог ресурсов сервера /var/lib/ambari-server/resources.

2. Создана символическая ссылка на этот драйвер (postgresql-jdbc.jar), что позволяет серверу автоматически находить нужный драйвер.

3. Подтверждено успешное завершение инициализации драйвера JDBC.

▌ Важные рекомендации:

- Если производится обновление существующего драйвера, удалите старый драйвер JDBC с всех узлов кластера Hadoop перед перезагрузкой сервисов.
- После изменения конфигурации потребуется перезапуск зависимых служб, чтобы новый драйвер начал использоваться.

Установка выполнена успешно, теперь Ambari готов взаимодействовать с базой данных PostgreSQL.

6. Инсталляция Ambari server

Выполнить:

```shell
ambari-server setup -s -j /usr/lib/jvm/java-1.8.0-openjdk --ambari-java-home /usr/lib/jvm/java-17-openjdk --database=postgres --databasehost=localhost --databaseport=5432 --databasename=ambari --databaseusername=ambari --databasepassword=admin
```

В процессе разворачивания Ambari server , будут выводиться вопросы:

Using python  /usr/bin/python3
Setup ambari-server
Checking SELinux...
SELinux status is 'disabled'
Customize user account for ambari-server daemon [y/n] (n)?
Adjusting ambari-server permissions and ownership...
Checking firewall status...
Checking JDK...
start setting AMBARI_JAVA_HOME for Ambari...
WARNING: AMBARI_JAVA_HOME /usr/lib/jvm/java-17-openjdk must be valid on ALL hosts
WARNING: JCE Policy files are required for configuring Kerberos security. If you plan to use Kerberos,please make sure JCE Unlimited Strength Jurisdiction Policy Files are valid on all hosts.
Setting AMBARI_JAVA_HOME for Ambari finished
WARNING: JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk must be valid on ALL hosts
WARNING: JCE Policy files are required for configuring Kerberos security. If you plan to use Kerberos,please make sure JCE Unlimited Strength Jurisdiction Policy Files are valid on all hosts.
Checking GPL software agreement...
GPL License for LZO: https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html
Enable Ambari Server to download and install GPL Licensed LZO packages [y/n] (n)?
Completing setup...
Configuring database...
Configuring database...
Configuring ambari database...
Configuring remote database connection properties...
WARNING: Before starting Ambari Server, you must run the following DDL directly from the database shell to create the schema: /var/lib/ambari-server/resources/Ambari-DDL-Postgres-CREATE.sql
Proceed with configuring remote database connection properties [y/n] (y)?
Extracting system views...
ambari-admin-3.0.0.0.0.jar

Ambari repo file doesn't contain latest json url, skipping repoinfos modification
Adjusting ambari-server permissions and ownership...
Ambari Server 'setup' completed successfully.


7. Запустить сервис Ambari Server:

```shell
   ambari-server start

# Вывод:
#Using python  /usr/bin/python3
#Starting ambari-server
#Ambari Server running with administrator privileges.
#Organizing resource files at /var/lib/ambari-server/resources...
#WARNING: Multiple versions of ehcache.jar found in java class path (/usr/lib/ambari-server/ehcache-3.10.0.jar and /usr/lib/ambari-server/ehcache-2.10.4.jar).
#Make sure that you include only one ehcache.jar in the java class path '/etc/ambari-server/conf:/usr/lib/ambari-server/*:/usr/share/java/postgresql-jdbc.jar'.
#Ambari database consistency check started...
#Server PID at: /var/run/ambari-server/ambari-server.pid
#Server out at: /var/log/ambari-server/ambari-server.out
#Server log at: /var/log/ambari-server/ambari-server.log
#Waiting for server start...........
#Server started listening on 8080

#DB configs consistency check found warnings. See /var/log/ambari-server/ambari-server-check-database.log for more details.
#Ambari Server 'start' completed successfully
```

7. Пример команды перезапуска сервиса Ambari Server

```shell
ambari-server restart

#Using python  /usr/bin/python3
#Restarting ambari-server
#Waiting for server stop...
#Ambari Server stopped
#Ambari Server running with administrator privileges.
#Organizing resource files at /var/lib/ambari-server/resources...
#Ambari database consistency check started...
#Server PID at: /var/run/ambari-server/ambari-server.pid
#Server out at: /var/log/ambari-server/ambari-server.out
#Server log at: /var/log/ambari-server/ambari-server.log
#Waiting for server start...........
#Server started listening on 8080
```

## Настройте и запустите агентов Ambari на всех узлах:

1. Отредактируйте конфигурационный файл ambari-agent
```shell
sed -i "s/hostname=.*/hostname=ambari-3-builder/" /etc/ambari-agent/conf/ambari-agent.ini
```
2. Запустите агент Ambari:
```shell
ambari-agent start
```

3. Проверка версии Ambari server:
```shell
ambari-server --version
```
4. Проверка состояния Ambari server:
```shell
ambari-server status

#Вывод
#Using python  /usr/bin/python3
#Ambari-server status
#Ambari Server not running.
```

## Обновление RPM хранилища пакетов

Чтобы обновить метаданные вашего RPM репозитория после изменения файлов пакетов, выполните следующую команду:

```shell
createrepo --update /opt/BigData/
```
Флаг --update позволяет создать новые метаданные только для тех пакетов, которые были изменены, сохраняя предыдущие записи неизменными. Это ускоряет процесс обновления больших репозиториев.

Таким образом, ваш порядок действий выглядит следующим образом:

1. Обновили пакеты в /opt/BigData/.
2. Выполняете команду обновления метаданных:

```shell
createrepo --update /opt/BigData/
```
Теперь ваши клиенты смогут видеть обновленные версии пакетов при обращении к этому репозиторию.

## Проверка установленных пакетов репозитория

yum list installed | grep @BIGTOP-3.5.0*

bigtop-groovy.noarch                           2.5.4-1.el9                      @BIGTOP-3.5.0-repo-1
bigtop-jsvc.x86_64                             1.4.0-1.el9                      @BIGTOP-3.5.0-repo-1
bigtop-select.noarch                           3.5.0-1.el9                      @BIGTOP-3.5.0-repo-1
bigtop-utils.noarch                            3.5.0-1.el9                      @BIGTOP-3.5.0-repo-1
hadoop_3_5_0.x86_64                            3.3.6-1.el9                      @BIGTOP-3.5.0-repo-1
hadoop_3_5_0-client.x86_64                     3.3.6-1.el9                      @BIGTOP-3.5.0-repo-1
hadoop_3_5_0-hdfs.x86_64                       3.3.6-1.el9                      @BIGTOP-3.5.0-repo-1
hadoop_3_5_0-libhdfs.x86_64                    3.3.6-1.el9                      @BIGTOP-3.5.0-repo-1
hadoop_3_5_0-mapreduce.x86_64                  3.3.6-1.el9                      @BIGTOP-3.5.0-repo-1
hadoop_3_5_0-yarn.x86_64                       3.3.6-1.el9                      @BIGTOP-3.5.0-repo-1
hbase_3_5_0.x86_64                             2.6.2-1.el9                      @BIGTOP-3.5.0-repo-1
hive_3_5_0.noarch                              4.0.1-1.el9                      @BIGTOP-3.5.0-repo-1
hive_3_5_0-hcatalog.noarch                     4.0.1-1.el9                      @BIGTOP-3.5.0-repo-1
hive_3_5_0-jdbc.noarch                         4.0.1-1.el9                      @BIGTOP-3.5.0-repo-1
hive_3_5_0-webhcat.noarch                      4.0.1-1.el9                      @BIGTOP-3.5.0-repo-1
ranger_3_5_0-hbase-plugin.x86_64               2.7.0-1.el9                      @BIGTOP-3.5.0-repo-1
ranger_3_5_0-hdfs-plugin.x86_64                2.7.0-1.el9                      @BIGTOP-3.5.0-repo-1
ranger_3_5_0-hive-plugin.x86_64                2.7.0-1.el9                      @BIGTOP-3.5.0-repo-1
ranger_3_5_0-yarn-plugin.x86_64                2.7.0-1.el9                      @BIGTOP-3.5.0-repo-1
tez_3_5_0.noarch                               0.10.4-1.el9                     @BIGTOP-3.5.0-repo-1
zookeeper_3_5_0.x86_64                         3.8.4-1.el9                      @BIGTOP-3.5.0-repo-1
