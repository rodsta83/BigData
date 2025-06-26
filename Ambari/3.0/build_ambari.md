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
ambari/ambari-agent/target/rpm/ambari-agent/RPMS/x86_64/ambari-agent-3.0.0.0-SNAPSHOT.x86_64.rpm

Ambari Server:  
ambari/ambari-server/target/rpm/ambari-server/RPMS/x86_64/ambari-server-3.0.0.0-SNAPSHOT.x86_64.rpm
