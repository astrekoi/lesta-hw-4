#!/bin/bash
# Если свалится одна из команд, рухнет и весь скрипт
set -xe

# Создаем необходимые директории
sudo mkdir -p /opt/sausage-store/bin
sudo mkdir -p /home/jarservice
sudo mkdir -p /var/sausage-store/logs
sudo mkdir -p /var/sausage-store/reports

# Настраиваем права доступа
sudo chown -R backend:backend /opt/sausage-store /home/jarservice /var/sausage-store 2>/dev/null || true
sudo chmod 777 /home/jarservice /opt/sausage-store/bin

# Создаем файл с переменными окружения из GitLab secrets
sudo bash -c "cat > /opt/sausage-store/env.conf << EOF
PSQL_USER=${PSQL_USER}
PSQL_PASSWORD=${PSQL_PASSWORD}
PSQL_HOST=${PSQL_HOST}
PSQL_DBNAME=${PSQL_DBNAME}
PSQL_PORT=${PSQL_PORT}
SPRING_DATASOURCE_URL=jdbc:postgresql://${PSQL_HOST}:${PSQL_PORT}/${PSQL_DBNAME}?ssl=true
SPRING_DATASOURCE_USERNAME=${PSQL_USER}
SPRING_DATASOURCE_PASSWORD=${PSQL_PASSWORD}
EOF"
sudo chmod 640 /opt/sausage-store/env.conf
sudo chown backend:backend /opt/sausage-store/env.conf

# Перезаливаем дескриптор сервиса на ВМ для деплоя
sudo cp -rf sausage-store-backend.service /etc/systemd/system/sausage-store-backend.service

# Скачиваем JAR-файл из Nexus
curl -u ${NEXUS_REPO_USER}:${NEXUS_REPO_PASS} -o sausage-store.jar ${NEXUS_REPO_URL}/repository/${NEXUS_REPO_BACKEND_NAME}/com/yandex/practicum/devops/sausage-store/${VERSION}/sausage-store-${VERSION}.jar

# Копируем JAR-файл в оба пути для совместимости
sudo cp -f ./sausage-store.jar /home/jarservice/sausage-store.jar || true
sudo cp -f ./sausage-store.jar /opt/sausage-store/bin/sausage-store-snapshot.jar || true

# Обновляем конфиг systemd с помощью рестарта
sudo systemctl daemon-reload

# Перезапускаем сервис сосисочной
sudo systemctl restart sausage-store-backend
