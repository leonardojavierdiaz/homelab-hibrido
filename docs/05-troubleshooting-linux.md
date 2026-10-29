# 05 · Troubleshooting Linux

Ejercicios hechos en el contenedor Debian: provoco la falla, la diagnostico y la resuelvo.

## Disco lleno

```bash
fallocate -l 2G /var/tmp/relleno      # provoco la falla
df -h                                 # confirmo qué filesystem está lleno
du -xh --max-depth=1 / | sort -h      # busco qué directorio ocupa más
```

## Archivo borrado que no libera espacio

Un proceso mantiene abierto un archivo borrado; `df` sigue mostrando el disco lleno.

```bash
lsof +L1        # archivos borrados que siguen abiertos, con el proceso dueño
```

**Solución:** reiniciar el servicio dueño del archivo. Si no se puede, vaciarlo con `: > /proc/<pid>/fd/<fd>`.

## Servicio que no arranca (nginx)

```bash
systemctl status nginx
journalctl -u nginx -n 50 --no-pager
nginx -t                # valida la configuración y marca la línea del error
```

## Puerto ocupado

```bash
ss -tulpn | grep :80    # qué proceso escucha en el puerto
```

## Proceso que consume CPU

```bash
top                     # ordenar por CPU con P
ps -eo pid,cmd,%cpu --sort=-%cpu | head
```

## SSH no responde pero el ping sí

```bash
nc -zv servidor 22      # desde afuera: refused (servicio caído) o timeout (firewall)
systemctl status sshd   # desde la consola
journalctl -u sshd
sshd -t                 # valida la configuración
ss -tlnp | grep :22
```
