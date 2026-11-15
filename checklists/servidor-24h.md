# Checklist — servidor 24/7 em VPS Linux

Checklist reutilizável. Siga o passo a passo em [VPS.md](../VPS.md). Não use o clone de referência como pasta de instalação. Fontes: [FATOS.md](../FATOS.md), F07–F18, F21, F30 e F69–F70.

## Preparar

- [ ] Linux AMD64 ou ARM64; ponto de partida de 2 núcleos, 8 GB de memória e 50 GB de disco. Reserve mais para concorrência ou modelos locais. (F07)
- [ ] Docker Engine 25 ou posterior em modo Linux, Compose v2 ou mais novo (plugin `docker compose`, versão principal ≥ 2), OpenSSL e sha256sum ou shasum. Git e Buildx também são necessários para build do código. O script SSH deste kit exige ainda Bash, Python 3, curl, ss, flock, nice e timeout. (F08)
- [ ] Rode `bash ferramentas/checar_servidor.sh` a partir deste kit. PRONTO significa apenas que as verificações locais passaram; não valida funcionamento do Nod, rede, Docker daemon ou capacidade sob carga.
- [ ] Defina se vai usar túnel SSH ou domínio com HTTPS. Mantenha backend, banco, workspace, browser e conexão Docker privados. Preserve o firewall `workspace-network` e os controles de metadata da VPS. (F14–F16)

## Rota automatizada deste kit: SSH privado

- [ ] Confirme a chave e a identidade do servidor numa primeira conexão SSH manual.
- [ ] Simule com `NOD_VPS_DRY=1 bash ferramentas/nod_vps.sh instalar usuario@host`.
- [ ] Instale com `bash ferramentas/nod_vps.sh instalar usuario@host --chave ~/.ssh/sua_chave`.
- [ ] Confira `status`: serviços com healthcheck devem estar healthy; auxiliares sem healthcheck devem estar running.
- [ ] Confirme bind `127.0.0.1:4310`, origin `http://localhost:4310` e restart `unless-stopped`.
- [ ] Abra `tunel` e obtenha `token` somente no seu terminal. Não grave a sessão.
- [ ] Faça onboarding por conta própria; não exponha a porta 1455 para callback ChatGPT.
- [ ] Antes de atualizar, espere as tarefas terminarem e use `atualizar --ref COMMIT_OU_TAG`; o backup é obrigatório.
- [ ] Se faltar memória/disco ou após duas falhas de build, pare. Não remova recursos alheios.

O script usa `NOD_BIND_ADDRESS` no `.env`. Não modifica o Compose nem gerencia HTTPS. Não mexe em nginx, certbot, firewall, serviços externos ou volumes alheios. Build tem teto de 90 minutos.

## Instalar manualmente por uma das rotas da doc

**Bundle, se disponível para sua conta:** a documentação clonada ainda descreve bundles privados. Não presuma acesso público. Confira a revisão completa e a arquitetura no GitHub autenticado; baixe o `.tar.gz` e seu `.sha256`. A alternativa documentada é o artifact de um workflow Self-host bundle bem-sucedido. Guarde o bundle. (F11–F12)

- [ ] Transfira os dois arquivos para uma pasta própria no servidor.
- [ ] Substitua os campos abaixo pelos nomes reais. Só avance se o checksum passar. (F12)

```bash
sha256sum -c nod-server-linux-<architecture>-<commit>.tar.gz.sha256
tar -xzf nod-server-linux-<architecture>-<commit>.tar.gz
cd nod-server-linux-<architecture>
sh install.sh
```

**Build do código oficial, como alternativa:** obtenha seu próprio checkout pelo [repositório oficial](https://github.com/n8n-io/nod). Dentro dele, entre em `deployment/self-host`. Esta rota não copia código para o kit. (F13)

```bash
sh setup.sh
# No .env, mantenha NOD_BIND_ADDRESS=127.0.0.1. PORT deve preceder NOD_PUBLIC_URL.
nice -n 10 timeout --kill-after=30s 90m docker compose up -d --build --wait
```

- [ ] Guarde o `.env` privado. O setup gera token, Vault key e senha do banco; preserva configuração existente. Não exponha os segredos. (F13)

## Acesso privado: túnel SSH

No seu computador cliente, mantenha esta conexão aberta. (F14)

```bash
ssh -L 4310:127.0.0.1:4310 <usuario>@<servidor>
```

- [ ] Abra `localhost` na porta `4310` com HTTP no navegador. Deixe `NOD_PUBLIC_URL` no padrão local e informe `NOD_AUTH_TOKEN` do `.env` do servidor. (F10, F14)
- [ ] Complete o onboarding e escolha o modelo. Para login ChatGPT remoto, use Callback URL se o retorno não abrir; não exponha a porta 1455 publicamente. (F21)

## Alternativa: domínio e HTTPS

- [ ] Aponte o domínio para o endereço público da VPS. Libere entrada TCP 80 e 443. (F15)
- [ ] No `.env`, defina `NOD_PUBLIC_URL` como origin HTTPS exata do seu domínio, sem caminho, parâmetros ou credenciais. (F15, F69)
- [ ] Para bundle, execute `sh install.sh --https`. Para código, use o comando abaixo. Caddy obtém e renova o certificado. (F15)

```bash
docker compose --profile https up -d --build --wait
```

- [ ] Mantenha `--profile https` nos comandos Compose de operação desta instalação (F69). Abra seu domínio com HTTPS e informe o token. Ele dá acesso completo, mesmo em rede privada. (F10, F15)
- [ ] Se conectar desktop remoto, use Connect to a server. Dados locais não são migrados. Fechar o cliente não para o servidor. (F10, F56)
- [ ] Em Channels, polling Telegram e WhatsApp QR dispensam domínio público; as opções de webhook exigem HTTPS público. (F30)

## Backup antes de atualizar

- [ ] Espere terminar o trabalho ativo. Mantenha configuração no `.env`, sem overrides de shell; o backup recusa `NOD_ENV_FILE`. (F17, F69)
- [ ] Na pasta da instalação oficial, rode o backup com caminho absoluto novo, cujo diretório pai já exista. O script para serviços durante a cópia e retoma os que estavam ativos. (F17)

```bash
sh backup.sh <caminho-absoluto-para-backup-novo>
```

- [ ] Confira `.env`, `postgres.dump`, `server-data.tar.gz`, `workspace-data.tar.gz`, `workspace-tools.tar.gz`, `browser-data.tar.gz`, `source-commit` e `complete`. Guarde cifrado, com acesso restrito, fora do servidor e junto do bundle. (F17–F18)
- [ ] Preserve a Vault key original. Só o banco não recupera as credenciais. Não apague volumes para atualizar. (F18)
- [ ] Para conferir recuperação, siga server-operations em instalação nova com a mesma revisão; não rode setup antes de restore. Pare o original antes de iniciar a cópia restaurada, para não duplicar schedules. Revise histórico, arquivos, modelos, credenciais no formulário privado, canais e schedules. (F18)

Fontes principais: `docs/src/content/docs/deploy/self-host.mdx` e `docs/src/content/docs/deploy/server-operations.md`. Passos completos na [documentação oficial](https://nod.n8n.io/docs/).
