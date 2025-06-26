## Локальный YUM репозиторий(хранилище RPM пакетов)

Установим зависимости  

```shell
dnf install createrepo nginx -y
```

Настройка веб-сервера (Nginx) для доступа к репозиторию:

```shell
dnf install createrepo nginx -y
```

Создаем папки для хранения RPM пакетов:

```shell
chmod -R 755 /var/www/html
chown -R nginx:nginx /var/www/html
createrepo /var/www/html/rocky8/
createrepo --update /var/www/html/rocky8/
```

Готовим конфиг nginx  ```/etc/nginx/conf.d/bigdata-builder.conf```:

```
server {
    listen       80;
    server_name  bigdata-builder;

    location / {
        root   /var/www/html/rocky8;
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
