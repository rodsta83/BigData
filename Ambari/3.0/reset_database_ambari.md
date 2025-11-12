

su - postgres

[postgres@vmi471366 ~]$ psql
psql (13.22)
Type "help" for help.

postgres=# DROP DATABASE IF EXISTS ambari;
DROP DATABASE


CREATE DATABASE ambari;

GRANT ALL PRIVILEGES ON DATABASE ambari TO ambari;

psql -d ambari -c "CREATE SCHEMA ambari;"

# Установить search_path по умолчанию для пользователя ambari
#sudo -u postgres psql -c "ALTER USER ambari SET search_path TO ambari, public;"

PGPASSWORD='admin' psql -h localhost -p 5432 -U ambari -d ambari \
-f /var/lib/ambari-server/resources/Ambari-DDL-Postgres-CREATE.sql

psql -d ambari -c "\dt"
Должны отобразиться таблицы Ambari.


ambari-server setup --jdbc-db=postgres --jdbc-driver=/usr/lib/ambari-server/postgresql-42.3.8.jar

ambari-server setup -s -j /usr/lib/jvm/java-1.8.0-openjdk --ambari-java-home /usr/lib/jvm/java-17-openjdk --database=postgres --databasehost=localhost --databaseport=5432 --databasename=ambari --databaseusername=ambari --databasepassword=admin

ambari-server start

