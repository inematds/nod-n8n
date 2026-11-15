# nod-n8n — kit de lectura y primeros pasos

**🇧🇷 [Português](README.md) · 🇺🇸 [English](README.en.md) · 🇪🇸 [Español](README.es.md)**

[![nod-n8n](guia/assets/banner-es.jpg)](https://inematds.github.io/nod-n8n/guia/es/)

## Qué es

Nod es un agente personal gratuito y de código abierto del equipo de n8n, que funciona en tu computadora con el modelo que elijas. Está pensado para quienes necesitan ayuda con tareas como resumir correos electrónicos, preparar reuniones y dar seguimiento a pendientes. Este kit ofrece consejos, tareas listas, listas de verificación y un comprobador de servidor para empezar con límites claros. Necesitas una computadora Mac, Windows o Linux compatible y un modelo: suscripción a ChatGPT Plus/Pro, clave de API o modelo local.

## 📖 Guía de uso

https://inematds.github.io/nod-n8n/guia/es/

Material educativo del INEMA, público y gratuito. La documentación indica que Nod es un agente personal de código abierto del equipo de n8n, con workspace y browser propios. Está en una vista previa de investigación. Este kit usa únicamente la documentación clonada; no es un relato de instalación o uso. Consulta [FATOS.md](FATOS.md), F01–F02.

- [FATOS.md](FATOS.md): afirmaciones, números y rutas de origen.
- [DICAS.md](DICAS.md): 25 consejos con fuentes y advertencias.
- [TAREFAS.md](TAREFAS.md): 12 solicitudes con aprobación y riesgo.
- [COMPARA.md](COMPARA.md): comparación limitada a lo que afirma la documentación.
- [Desktop](checklists/instalar-desktop.md), [servidor 24/7](checklists/servidor-24h.md) y [seguridad](checklists/seguranca-primeiro-dia.md): listas de verificación.
- [Verificador](ferramentas/checar_servidor.sh) y [prueba](ferramentas/test_checar_servidor.sh): verificación local, sin instalación.


## El proceso, de principio a fin

1. Lee FATOS.md y sus salvedades. La fecha de lanzamiento y la versión del contexto no se confirmaron en las páginas consultadas.
2. Elige desktop o servidor y lee la lista de verificación correspondiente.
3. Para el servidor, ejecuta `bash ferramentas/checar_servidor.sh` y revisa cada línea.
4. Cuando decidas instalar, sigue la documentación oficial fuera de este kit. Esta fase no inicia Nod ni Docker.
5. Revisa la privacidad, el modelo, los permisos y el límite de gasto en la lista de verificación de seguridad.
6. Elige una solicitud de TAREFAS.md, sustituye los campos y revisa el resultado en Usage.
7. Solo después amplía las conexiones, revisa la memoria y configura rutinas; mantén una copia de seguridad en el servidor.

Los pasos del producto remiten a FATOS.md, F03–F18, F24–F35 y F44–F64. Son instrucciones para que las ejecutes, no acciones realizadas aquí.

## Verificar las herramientas

```bash
bash ferramentas/test_checar_servidor.sh
bash ferramentas/checar_servidor.sh
```

El verificador es de solo lectura y no ejecuta Docker, instala paquetes, usa sudo ni accede a la red. Verifica el disco del directorio actual. Usa GB decimales para comparar los valores de la documentación: 8 GB = 8.000.000.000 bytes y 50 GB = 50.000.000.000 bytes. Esta conversión es una convención del kit; la documentación no especifica GB versus GiB.

Docker y Compose se verifican mediante metadatos de paquetes instalados (dpkg o RPM) y la presencia del comando Docker. Las instalaciones manuales o Docker Desktop pueden requerir una verificación aparte: una versión no confirmada genera FALTA. El requisito es Compose v2 o posterior: el plugin usado por `docker compose`, con versión principal ≥ 2 (por ejemplo, 5.2.0). Compose 1.29 genera FALTA. El script no valida el daemon, el modo Linux, los permisos de uso ni la versión que carga efectivamente un plugin manual. PRONTO es solo el resultado de las verificaciones implementadas, no una validación operativa de Nod.

Para simular sin leer la máquina, usa `CHECAR_FAKE=1` y las variables `CHECAR_FAKE_ARCH`, `CHECAR_FAKE_CORES`, `CHECAR_FAKE_MEM_BYTES`, `CHECAR_FAKE_DISK_BYTES`, `CHECAR_FAKE_DOCKER_VERSION`, `CHECAR_FAKE_COMPOSE_VERSION`, `CHECAR_FAKE_OPENSSL` y `CHECAR_FAKE_HASH`. Las dos últimas aceptan `1` (presente) o `0` (ausente). La prueba muestra ejemplos. Salida: OK/FALTA por elemento; resumen PRONTO con código 0 o FALTA con código 1.

Fuentes oficiales: [Nod](https://nod.n8n.io), [documentación](https://nod.n8n.io/docs/) y [código oficial](https://github.com/n8n-io/nod). El código de Nod no forma parte de este repo.
