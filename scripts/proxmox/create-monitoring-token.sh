#!/usr/bin/env bash
# Crea un token de API de solo lectura para que Zabbix monitoree Proxmox.
# Ejecutar en el nodo Proxmox como root.
set -euo pipefail

USER_ID="root@pam"
TOKEN_NAME="zabbix"

# Token con separación de privilegios: solo tiene los permisos que se le asignan.
pveum user token add "$USER_ID" "$TOKEN_NAME" --privsep 1

# Rol PVEAuditor (solo lectura) sobre todo el datacenter.
pveum acl modify / --tokens "${USER_ID}!${TOKEN_NAME}" --roles PVEAuditor

echo "Token creado: ${USER_ID}!${TOKEN_NAME}"
echo "Guardá el secreto que se mostró arriba en un gestor de secretos. No se vuelve a mostrar."
