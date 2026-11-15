# nod-n8n — kit de leitura e primeiros passos

**🇧🇷 [Português](README.md) · 🇺🇸 [English](README.en.md) · 🇪🇸 [Español](README.es.md)**

[![nod-n8n](guia/assets/banner.jpg)](https://inematds.github.io/nod-n8n/guia/)

## O que é

O Nod é um agente pessoal grátis e de código aberto da equipe da n8n, que roda no seu computador com o modelo que você escolhe. É para quem quer ajuda com tarefas como resumir e-mails, preparar reuniões e acompanhar pendências. Este kit entrega dicas, tarefas prontas, checklists e um checador de servidor para começar com limites claros. Você precisa de um computador Mac, Windows ou Linux compatível e de um modelo: assinatura ChatGPT Plus/Pro, chave de API ou modelo local.

## 📖 Guia de uso

https://inematds.github.io/nod-n8n/guia/

Material educativo do INEMA, público e gratuito. A documentação diz que Nod é um agente pessoal open source da equipe da n8n, com workspace e browser próprios. Está em prévia de pesquisa. A base deste kit é a documentação oficial clonada. A instalação privada numa VPS foi verificada separadamente; veja [VPS.md](VPS.md). Veja [FATOS.md](FATOS.md), F01–F02.

- [FATOS.md](FATOS.md): afirmações, números e caminhos de origem.
- [DICAS.md](DICAS.md): 25 dicas com fontes e pegadinhas.
- [TAREFAS.md](TAREFAS.md): 12 pedidos com aprovação e risco.
- [COMPARA.md](COMPARA.md): comparação limitada ao que a doc afirma.
- [Desktop](checklists/instalar-desktop.md), [servidor 24/7](checklists/servidor-24h.md) e [segurança](checklists/seguranca-primeiro-dia.md): checklists.
- [Verificador](ferramentas/checar_servidor.sh) e [teste](ferramentas/test_checar_servidor.sh): conferência local, sem instalação.


## O processo, do início ao fim

1. Leia FATOS.md e suas ressalvas. A data de lançamento e a versão do contexto não foram confirmadas nas páginas consultadas.
2. Escolha desktop ou servidor e leia o checklist correspondente.
3. Para servidor, siga [VPS.md](VPS.md). O [script SSH](ferramentas/nod_vps.sh) confere requisitos remotos e instala com acesso privado por túnel.
4. Use `bash ferramentas/nod_vps.sh instalar usuario@host --chave ~/.ssh/sua_chave`. Depois abra o túnel com `tunel` e consulte o token com `token`, no seu terminal. Faça o onboarding com sua conta.
5. Revise privacidade, modelo, permissões e limite de gasto no checklist de segurança.
6. Escolha um pedido de TAREFAS.md, substitua os campos e confira o resultado em Usage.
7. Só depois amplie as conexões, revise memória e configure rotinas; mantenha backup no servidor.

Os passos de produto remetem a FATOS.md, F03–F18, F24–F35 e F44–F64. O onboarding, os modelos e as conexões são etapas para você executar com sua conta.

## Conferir as ferramentas

```bash
bash ferramentas/test_checar_servidor.sh
bash ferramentas/test_nod_vps.sh
bash ferramentas/checar_servidor.sh
```

O verificador é só leitura e não executa Docker, instala pacotes, usa sudo ou acessa rede. Confere o disco do diretório atual. Usa GB decimais para comparar os valores da doc: 8 GB = 8.000.000.000 bytes e 50 GB = 50.000.000.000 bytes. Essa conversão é uma convenção do kit; a doc não especifica GB versus GiB.

Docker e Compose são conferidos por metadados de pacotes instalados (dpkg ou RPM) e presença do comando Docker. Instalações manuais ou Docker Desktop podem exigir conferência separada: versão não confirmada gera FALTA. O requisito é Compose v2 ou mais novo: o plugin usado por `docker compose`, com versão principal ≥ 2 (por exemplo, 5.2.0). Compose 1.29 gera FALTA. O script não valida o daemon, modo Linux, permissões de uso ou a versão efetivamente carregada por um plugin manual. PRONTO é só resultado das verificações implementadas, não validação operacional do Nod.

Para simular sem ler a máquina, use `CHECAR_FAKE=1` e as variáveis `CHECAR_FAKE_ARCH`, `CHECAR_FAKE_CORES`, `CHECAR_FAKE_MEM_BYTES`, `CHECAR_FAKE_DISK_BYTES`, `CHECAR_FAKE_DOCKER_VERSION`, `CHECAR_FAKE_COMPOSE_VERSION`, `CHECAR_FAKE_OPENSSL` e `CHECAR_FAKE_HASH`. Os dois últimos aceitam `1` (presente) ou `0` (ausente). O teste mostra exemplos. Saída: OK/FALTA por item; resumo PRONTO com código 0 ou FALTA com código 1.

Fontes oficiais: [Nod](https://nod.n8n.io), [documentação](https://nod.n8n.io/docs/) e [código oficial](https://github.com/n8n-io/nod). O código do Nod não faz parte deste repo.
