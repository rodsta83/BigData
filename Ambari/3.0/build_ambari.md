# Сборка Apache Ambari 3.0 через maven. Создание RPM-пакетов


Сборка Ambari и создание RPM пакетов:  
Текущая активаня версия java должна быть версии 17

```shell
mvn -B -T 2C clean install package rpm:rpm \
-Drat.skip=true \
-DskipTests \
-Dmaven.test.skip=true \
-Dfindbugs.skip=true \
-Dcheckstyle.skip=true
```

Пакеты RPM будут созданы по адресу:

Ambari Agent:  
ambari/ambari-agent/target/rpm/ambari-agent/RPMS/x86_64/ambari-agent-3.0.0.0-SNAPSHOT.x86_64.rpm

Ambari Server:  
ambari/ambari-server/target/rpm/ambari-server/RPMS/x86_64/ambari-server-3.0.0.0-SNAPSHOT.x86_64.rpm
