## Локальный YUM репозиторий(хранилище RPM пакетов)

Локальный репозиторий поставим на билд машину.
Нам понадобятся следующие пакеты createrepo и nginx: 

```shell
dnf install createrepo nginx -y
```

Настройка веб-сервера (Nginx) для доступа к репозиторию:

```shell
dnf install createrepo nginx -y
```

Для целей разработки и тестирования рекомендуется отключить firewall и selinux:  

```shell
systemctl stop firewalld
systemctl disable firewalld
```

Откройте на редактирование nano ```/etc/selinux/config``` и установите параметр ```SELINUX=disabled```


Создаем папки для хранения RPM пакетов.  
Мы сделаем две папки ambari_repo и rocky8 - в этой папке мы будем хранить компоненты BigTop 3.0 собранные под rocky linux 8.X

```shell
mkdir -p /var/www/html
mkdir -p /var/www/html/ambari_repo
mkdir -p /var/www/html/ambari_repo/ambari-3.0
mkdir -p /var/www/html/rocky8
chmod -R 755 /var/www/html
chown -R nginx:nginx /var/www/html
createrepo /var/www/html/
cp /opt/ambari_server_3_0/ambari/ambari-agent/target/rpm/ambari-agent/RPMS/x86_64/*.rpm /var/www/html/ambari_repo/
cp /opt/ambari_server_3_0/ambari/ambari-server/target/rpm/ambari-server/RPMS/x86_64/*.rpm /var/www/html/ambari_repo/
createrepo --update /var/www/html/
```

Готовим конфиг nginx  ```/etc/nginx/conf.d/ambari_repo.conf```:

```
server {
    listen       80;
    server_name  bigdata-builder;

    location / {
        root   /var/www/html/ambari_repo;
        autoindex on;
        index  index.html index.htm;
        default_type text/html;
    }

    # Отключение логов для favicon.ico и robots.txt (опционально)
    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }
}

```
Проверяем конфиг nginx и перезапускаем:

```shell
nginx -t
systemctl status nginx
systemctl start nginx
systemctl enable nginx
```
Пробуем по http обратиться в браузере к ропозиторию ```http://bigdata-builder/```

В браузере вы должны увидеть RPM пакеты собранных ambari-server и ambari-agent:

```
ambari-3.0/                                        27-Jun-2025 08:09      
        ambari-agent-3.0.0.0-0.x86_64.rpm                  27-Jun-2025 07:03            35358426
        ambari-server-3.0.0.0-0.x86_64.rpm                 27-Jun-2025 07:04           138640049
```