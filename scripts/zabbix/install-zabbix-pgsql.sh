#!/usr/bin/env bash
# Instala Zabbix 7.0 LTS (servidor, frontend y agente) con PostgreSQL y Apache
# en Debian 13 arm64 (contenedor LXC). Ejecutar como root.
set -euo pipefail

ZBX_RELEASE="zabbix-release_latest_7.0+debian13_all.deb"
ZBX_URL="https://repo.zabbix.com/zabbix/7.0/debian-arm64/pool/main/z/zabbix-release/${ZBX_RELEASE}"

# La contraseña de la base se pide en tiempo de ejecución: nunca va en el script.
read -rsp "Contraseña para el usuario zabbix de PostgreSQL: " DB_PASS; echo

# 1. Repositorio de Zabbix para arm64
apt-get update
apt-get install -y wget locales
wget -q "$ZBX_URL" -O "/tmp/${ZBX_RELEASE}"
dpkg -i "/tmp/${ZBX_RELEASE}"
apt-get update

# 2. Paquetes (incluye el servidor PostgreSQL, que no viene por defecto)
apt-get install -y postgresql zabbix-server-pgsql zabbix-frontend-php php-pgsql \
  zabbix-apache-conf zabbix-sql-scripts zabbix-agent

# 3. Locale que necesita el frontend
sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen

# 4. Base de datos (sin sudo: el contenedor no lo trae)
su - postgres -c "psql -c \"CREATE USER zabbix WITH PASSWORD '${DB_PASS}';\""
su - postgres -c "createdb -O zabbix zabbix"

SCHEMA=/usr/share/zabbix/sql-scripts/postgresql/server.sql.gz
[ -f "$SCHEMA" ] || SCHEMA=/usr/share/zabbix-sql-scripts/postgresql/server.sql.gz
zcat "$SCHEMA" | PGPASSWORD="$DB_PASS" psql -h localhost -U zabbix -d zabbix -q

# 5. Configuración del servidor
sed -i "s/^# DBPassword=.*/DBPassword=${DB_PASS}/" /etc/zabbix/zabbix_server.conf

# 6. Servicios
systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2

echo "Listo. Frontend en http://$(hostname -I | awk '{print $1}')/zabbix"
echo "Usuario inicial Admin / zabbix: cambiá la contraseña en el primer ingreso."
