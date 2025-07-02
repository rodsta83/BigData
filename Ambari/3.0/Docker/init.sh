#!/bin/bash

# Проверка, были ли зависимости установлены ранее
MARKER_FILE="/.dependencies_installed"
if [[ ! -f $MARKER_FILE ]]; then
    echo "Installing required dependencies..."
    # Установка базовых утилит
    dnf install -y sudo openssh-server openssh-clients which iproute net-tools less vim-enhanced
    # Установка инструментов разработки
    dnf install -y initscripts wget curl tar unzip git
    # Включение репозитория PowerTools
    dnf install -y dnf-plugins-core
    dnf config-manager --set-enabled powertools
    # Обновление системы
    dnf update -y
    # Создание маркера завершения установки
    touch $MARKER_FILE
    echo "Dependencies installed successfully!"
fi

# Запуск основной команды контейнера
exec /sbin/init "$@"