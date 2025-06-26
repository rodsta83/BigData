# Подготовка Build-машины: Настройка окружения.

Для Build-машины возмем за основу дистрибутив Rocky linux 9

Установка обновлений и базовых утилит (dnf update, git, wget).

```shell
dnf update -y
dnf install wget tar gzip -y
dnf install openssl-devel git wget curl zip unzip -y
```

Установка зависимостей, потребуются следующие версии java:  
Основной проект Ambari Server\Agent: `JDK 17`  
Ambari Metrics: `JDK 8`  
Ambari Infra: `JDK 8`

```shell
dnf install -y java-17-openjdk-devel
dnf install -y java-1.8.0-openjdk-devel
```

Maven для сборки проектов и скачивания зависимостей:

```shell
MAVEN_VERSION="3.9.10"

wget https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz

tar -xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt

ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven
```
Настраиваем переменное окружение maven:

```shell
tee /etc/profile.d/maven.sh <<EOF
export M2_HOME=/opt/maven
export PATH=\$M2_HOME/bin:\$PATH
EOF

source /etc/profile.d/maven.sh
```
Проверяем версию maven:

```shell
mvn -version
```

Проверка установленных версий java:

```shell
alternatives --config java
```
Вывод должны получить следующий:

```shell
There are 2 programs which provide 'java'.

  Selection    Command
-----------------------------------------------
*+ 1           java-17-openjdk.x86_64 (/usr/lib/jvm/java-17-openjdk-17.0.15.0.6-3.el9.x86_64/bin/java)
   2           java-1.8.0-openjdk.x86_64 (/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.452.b09-3.el9.x86_64/jre/bin/java)
```

Установка ядра python3:

```shell
dnf install -y python3 python3-devel python3-pip
```

Инструменты для RPM:

```shell
dnf install -y rpm-build
```

