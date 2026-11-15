# nod-n8n — reading kit and getting started

**🇧🇷 [Português](README.md) · 🇺🇸 [English](README.en.md) · 🇪🇸 [Español](README.es.md)**

[![nod-n8n](guia/assets/banner-en.jpg)](https://inematds.github.io/nod-n8n/guia/en/)

## What it is

Nod is a free, open-source personal agent from the n8n team that runs on your computer with the model you choose. It’s for people who want help with tasks such as summarizing emails, preparing for meetings, and tracking to-dos. This kit provides tips, ready-to-use tasks, checklists, and a server checker to help you get started with clear limits. You need a compatible Mac, Windows, or Linux computer and a model: a ChatGPT Plus/Pro subscription, an API key, or a local model.

## 📖 User guide

https://inematds.github.io/nod-n8n/guia/en/

Educational material from INEMA, free and open to the public. The documentation says Nod is an open-source personal agent from the n8n team, with its own workspace and browser. It is in research preview. This kit uses only the cloned documentation; it is not an account of an installation or use. See [FATOS.md](FATOS.md), F01–F02.

- [FATOS.md](FATOS.md): claims, numbers, and source paths.
- [DICAS.md](DICAS.md): 25 tips with sources and gotchas.
- [TAREFAS.md](TAREFAS.md): 12 requests with approval and risk.
- [COMPARA.md](COMPARA.md): comparison limited to what the docs state.
- [Desktop](checklists/instalar-desktop.md), [24/7 server](checklists/servidor-24h.md), and [security](checklists/seguranca-primeiro-dia.md): checklists.
- [Checker](ferramentas/checar_servidor.sh) and [test](ferramentas/test_checar_servidor.sh): local checks, no installation required.


## The process, from start to finish

1. Read FATOS.md and its caveats. The release date and context version have not been confirmed on the pages consulted.
2. Choose desktop or server and read the corresponding checklist.
3. For a server, run `bash ferramentas/checar_servidor.sh` and review each line.
4. When you decide to install, follow the official documentation outside this kit. This step does not start Nod or Docker.
5. Review privacy, model, permissions, and spending limit in the security checklist.
6. Choose a request from TAREFAS.md, replace the fields, and check the result in Usage.
7. Only then expand the connections, review memory, and configure routines; keep a backup on the server.

The product steps refer to FATOS.md, F03–F18, F24–F35, and F44–F64. They are instructions for you to carry out, not actions performed here.

## Check the tools

```bash
bash ferramentas/test_checar_servidor.sh
bash ferramentas/checar_servidor.sh
```

The checker is read-only and does not run Docker, install packages, use sudo, or access the network. It checks the current directory’s disk. It uses decimal GB to compare the values in the docs: 8 GB = 8.000.000.000 bytes and 50 GB = 50.000.000.000 bytes. This conversion is a convention used by the kit; the docs do not specify GB versus GiB.

Docker and Compose are checked using metadata for installed packages (dpkg or RPM) and the presence of the Docker command. Manual installations or Docker Desktop may require a separate check: an unconfirmed version is reported as MISSING. The requirement is Compose v2 or newer: the plugin used by `docker compose`, with a major version ≥ 2 (for example, 5.2.0). Compose 1.29 is reported as MISSING. The script does not validate the daemon, Linux mode, usage permissions, or the version actually loaded by a manually installed plugin. READY only means the implemented checks passed; it does not validate Nod’s operational readiness.

To simulate without reading the machine, use `CHECAR_FAKE=1` and the variables `CHECAR_FAKE_ARCH`, `CHECAR_FAKE_CORES`, `CHECAR_FAKE_MEM_BYTES`, `CHECAR_FAKE_DISK_BYTES`, `CHECAR_FAKE_DOCKER_VERSION`, `CHECAR_FAKE_COMPOSE_VERSION`, `CHECAR_FAKE_OPENSSL`, and `CHECAR_FAKE_HASH`. The last two accept `1` (present) or `0` (absent). The test shows examples. Output: OK/MISSING for each item; summary READY with code 0 or MISSING with code 1.

Official sources: [Nod](https://nod.n8n.io), [documentation](https://nod.n8n.io/docs/), and [official code](https://github.com/n8n-io/nod). Nod’s code is not part of this repo.
