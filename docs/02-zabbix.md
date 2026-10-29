# 02 · Zabbix 7.0 LTS en un contenedor LXC

## Decisiones

- **Versión:** 7.0 LTS, por soporte de largo plazo.
- **Base de datos y web:** PostgreSQL + Apache.
- **Repositorio:** el específico para arm64 (`/zabbix/7.0/debian-arm64/`), porque el genérico es para amd64.

Script de instalación: [`scripts/zabbix/install-zabbix-pgsql.sh`](../scripts/zabbix/install-zabbix-pgsql.sh)

## Detalles de los contenedores mínimos

Un contenedor Debian mínimo no trae algunas piezas que la guía oficial da por sentadas. El script de instalación ya las contempla.

| Síntoma | Causa | Solución |
|---|---|---|
| `su - postgres` falla: no existe el usuario | El servidor PostgreSQL no estaba instalado, solo el cliente | `apt install postgresql` |
| `sudo: command not found` | El contenedor Debian no trae sudo | `su - postgres -c "..."` |
| El frontend se queja del locale | Faltaba `en_US.UTF-8` | Descomentar en `/etc/locale.gen` y `locale-gen` |

## Monitoreo de Proxmox por API

En vez de instalar un agente en el hipervisor, usé el template **Proxmox VE by HTTP**, que consulta la API.

**Mínimo privilegio:** creé un token `root@pam!zabbix` con *privilege separation* y le di solo el rol **PVEAuditor** (lectura). El monitoreo no necesita más que eso.

Script: [`scripts/proxmox/create-monitoring-token.sh`](../scripts/proxmox/create-monitoring-token.sh)

Macros del host en Zabbix:

| Macro | Valor |
|---|---|
| `{$PVE.URL.HOST}` | IP del nodo Proxmox |
| `{$PVE.TOKEN.ID}` | `root@pam!zabbix` |
| `{$PVE.TOKEN.SECRET}` | Secreto del token (macro de tipo *Secret text*) |

> El secreto nunca va al repositorio. Si se expone, se revoca y se genera uno nuevo.

## Próximos pasos

- Despliegue de agentes con Ansible.
- Autorregistro de hosts por sistema operativo.
- Dependencias entre triggers y umbrales con duración, para evitar alertas falsas.
