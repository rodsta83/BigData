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
В выводе мы должны увидеть первым шагом происходит скачивание зависимостей maven:
```shell
[INFO] Scanning for projects...
[INFO] Downloading from oss.sonatype.org: https://oss.sonatype.org/content/groups/staging/org/apache/apache/21/apache-21.pom
[INFO] Downloading from spring-milestones: https://repo.spring.io/milestone/org/apache/apache/21/apache-21.pom
[INFO] Downloading from ASF Staging: https://repository.apache.org/content/groups/staging/org/apache/apache/21/apache-21.pom
[INFO] Downloaded from ASF Staging: https://repository.apache.org/content/groups/staging/org/apache/apache/21/apache-21.pom (17 kB at 61 kB/s)
[INFO] Downloading from maven2-repository.dev.java.net: https://download.java.net/maven/2/org/apache/maven/wagon/wagon-ssh-external/maven-metadata.xml
[INFO] Downloading from maven2-repository.atlassian: https://maven.atlassian.com/repository/public/org/apache/maven/wagon/wagon-ssh-external/maven-metadata.xml
[INFO] Downloading from maven2-glassfish-repository.dev.java.net: https://download.java.net/maven/glassfish/org/apache/maven/wagon/wagon-ssh-external/maven-metadata.xml
[INFO] Downloading from apache.snapshots.https: https://repository.apache.org/content/repositories/snapshots/org/apache/maven/wagon/wagon-ssh-external/maven-metadata.xml
[INFO] Downloaded from apache.snapshots.https: https://repository.apache.org/content/repositories/snapshots/org/apache/maven/wagon/wagon-ssh-external/maven-metadata.xml (486 B at 8.7 kB/s)
[INFO] Downloading from central: https://repo.maven.apache.org/maven2/org/apache/maven/wagon/wagon-ssh-external/maven-metadata.xml
[INFO] Downloaded from central: https://repo.maven.apache.org/maven2/org/apache/maven/wagon/wagon-ssh-external/maven-metadata.xml (1.6 kB at 5.5 kB/s)
[INFO] Downloaded from maven2-repository.atlassian: https://maven.atlassian.com/repository/public/org/apache/maven/wagon/wagon-ssh-external/maven-metadata.xml (430 B at 456 B/s)
[INFO] Downloading from maven2-repository.dev.java.net: https://download.java.net/maven/2/org/apache/maven/wagon/wagon-ssh-external/3.5.3/wagon-ssh-external-3.5.3.pom
[INFO] Downloading from maven2-glassfish-repository.dev.java.net: https://download.java.net/maven/glassfish/org/apache/maven/wagon/wagon-ssh-external/3.5.3/wagon-ssh-external-3.5.3.pom
[INFO] Downloading from maven2-repository.atlassian: https://maven.atlassian.com/repository/public/org/apache/maven/wagon/wagon-ssh-external/3.5.3/wagon-ssh-external-3.5.3.pom
[INFO] Downloading from apache.snapshots.https: https://repository.apache.org/content/repositories/snapshots/org/apache/maven/wagon/wagon-ssh-external/3.5.3/wagon-ssh-external-3.5.3.pom
[INFO] Downloading from central: https://repo.maven.apache.org/maven2/org/apache/maven/wagon/wagon-ssh-external/3.5.3/wagon-ssh-external-3.5.3.pom
```

Пакеты RPM будут созданы по адресу:

Ambari Agent:  
```
ambari/ambari-agent/target/rpm/ambari-agent/RPMS/x86_64/ambari-agent-3.0.0.0-SNAPSHOT.x86_64.rpm
```
Ambari Server:  
```
ambari/ambari-server/target/rpm/ambari-server/RPMS/x86_64/ambari-server-3.0.0.0-SNAPSHOT.x86_64.rpm
```

Результат успешной сборки вы увидите в консоли:

```
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Summary for Ambari Main 3.0.0.0.0:
[INFO]
[INFO] Ambari Main ........................................ SUCCESS [ 33.962 s]
[INFO] Apache Ambari Project POM .......................... SUCCESS [  0.160 s]
[INFO] Ambari Web ......................................... SUCCESS [03:33 min]
[INFO] Ambari Views ....................................... SUCCESS [ 15.568 s]
[INFO] Ambari Admin View .................................. SUCCESS [ 20.345 s]
[INFO] ambari-utility ..................................... SUCCESS [07:57 min]
[INFO] Ambari Server SPI .................................. SUCCESS [  1.019 s]
[INFO] Ambari Service Advisor ............................. SUCCESS [  1.795 s]
[INFO] Ambari Server ...................................... SUCCESS [  01:19 h]
[INFO] Ambari Functional Tests ............................ SUCCESS [ 52.022 s]
[INFO] Ambari Agent ....................................... SUCCESS [08:52 min]
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  01:41 h
[INFO] Finished at: 2025-06-26T18:29:27+03:00
[INFO] ------------------------------------------------------------------------
```



Возможные проблемы:

1. Если в процессе сборки вы получили ошибку failed: Could not acquire lock(s) , такая ошибка может возникать при параллельной сборке.
Тогда рекомендуется из команды ```mvn -B -T 2C``` , убрать параметр ```-T 2C``` - отвечающий за многопоточную сборку.

Тогда выполните команду:

```shell
mvn -B clean install package rpm:rpm \
-Drat.skip=true \
-DskipTests \
-Dmaven.test.skip=true \
-Dfindbugs.skip=true \
-Dcheckstyle.skip=true
```

2. Возможны сетевые блокировки к внешним репозиториям maven: ```Connect to repository.apache.org:443 failed: Connect timed out```
В этом случае добавьте зеркало в settings.xml  
Это решит проблемы доступа к основным репозиториям

```
<mirror>
  <id>central-mirror</id>
  <name>Central Mirror</name>
  <url>https://repo1.maven.org/maven2/</url>
  <mirrorOf>central</mirrorOf>
</mirror>
```