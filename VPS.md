# Nod numa VPS, com acesso privado

Uma VPS é um computador alugado que fica ligado num datacenter. O Nod continua funcionando quando seu computador pessoal está desligado. Cada servidor Nod pertence a uma pessoa. O token dá acesso completo ao assistente e às contas conectadas.

## 1. Preparar o servidor e a chave

Comece com Linux AMD64 ou ARM64, 2 núcleos, 8 GB de RAM e 50 GB livres. Mais tarefas simultâneas e modelos locais pedem mais recursos.

No servidor, tenha Docker Engine 25 ou posterior, Compose v2 ou posterior, Buildx, Git, OpenSSL, sha256sum ou shasum, Python 3, curl, ss, flock, nice e timeout. O script confere as versões efetivas de Docker e Compose, o daemon Linux e os mesmos mínimos de capacidade do `checar_servidor.sh`. Também recusa uma build com menos de 2 GB de RAM disponível. Ele não instala pacotes nem limpa disco.

No seu computador, use Bash e OpenSSH. No Windows, pode usar WSL. Crie uma chave, caso ainda não tenha:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/chave_vps
```

Cadastre **somente a chave pública**, `~/.ssh/chave_vps.pub`, no painel do provedor ou na conta do servidor. Guarde a privada com você. Troque `usuario@servidor.example` nos exemplos pelo seu acesso real.

```bash
ssh -i ~/.ssh/chave_vps usuario@servidor.example
```

Na primeira conexão, confira a impressão digital do servidor pelo provedor. Depois saia com `exit`. O script usa `BatchMode=yes`: não abre perguntas de senha ou confirmação. Para chave protegida por senha, carregue-a antes com `ssh-add ~/.ssh/chave_vps`.

O usuário remoto precisa acessar o Docker e escrever em `/opt/nod`. Pode usar uma conta administrativa ou escolher `--pasta /home/usuario/nod`. O script não usa sudo automaticamente. Acesso ao Docker equivale a acesso administrativo ao host.

## 2. Instalar

Execute na raiz deste kit, no seu computador:

```bash
bash ferramentas/nod_vps.sh --help
NOD_VPS_DRY=1 bash ferramentas/nod_vps.sh instalar usuario@servidor.example
bash ferramentas/nod_vps.sh instalar usuario@servidor.example --chave ~/.ssh/chave_vps
```

A instalação clona o repositório oficial na VPS. Executa `setup.sh`, que gera os segredos dentro de `deployment/self-host/.env`. Define `NOD_BIND_ADDRESS=127.0.0.1` e `PORT=4310`, sem editar o Compose. Depois roda `nice -n 10 timeout --kill-after=30s 90m docker compose up -d --build --wait`.

A primeira build demora: baixa dependências e ferramentas de navegador. Mantenha o terminal aberto. `nice` reduz a prioridade do cliente; não impõe um limite de CPU ao daemon Docker. O timeout limita o comando. Em caso de interrupção, consulte o estado antes de repetir; ele não desfaz imagens ou containers já criados.

Não há retry automático. Se faltar RAM/disco, pare. Depois de duas falhas de build, pare e guarde o erro sem segredos. Não apague imagens ou volumes de outros projetos.

Em checkout novo, o script faz `git pull --ff-only`. Com `.env` existente, preserva a revisão; use `atualizar --ref` para trocar a versão com backup. Reexecutar `instalar` também pode iniciar um Nod que você parou.

Para outro diretório ou porta, passe `--pasta /srv/nod` e `--porta 54310`. Repita essas opções nos comandos seguintes. O script não guarda um cadastro de servidores. Use uma pasta diferente para outro assistente e preserve o `COMPOSE_PROJECT_NAME` criado pelo setup.

## 3. Conferir e abrir

```bash
bash ferramentas/nod_vps.sh status usuario@servidor.example --chave ~/.ssh/chave_vps
bash ferramentas/nod_vps.sh tunel usuario@servidor.example --chave ~/.ssh/chave_vps
```

Abra **http://localhost:4310**. Mantenha o túnel aberto. Ctrl+C fecha o túnel, mas o Nod continua ligado. O túnel também escuta somente em `127.0.0.1` no seu computador.

Em outro terminal, peça o token:

```bash
bash ferramentas/nod_vps.sh token usuario@servidor.example --chave ~/.ssh/chave_vps
```

Ele aparece somente num terminal interativo. Cole no campo de acesso do Nod. Não cole no chat, não redirecione a saída e não grave a sessão. O arquivo original é `/opt/nod/deployment/self-host/.env`, na VPS. Nunca publique esse arquivo.

Use **localhost**, não o IP 127.0.0.1 na barra do navegador. O Nod confere o Host com `NOD_PUBLIC_URL`; um Host diferente recebe HTTP 403. `tunel --local 14310` cria o encaminhamento alternativo, mas o navegador nessa porta também será recusado enquanto a origem continuar `http://localhost:4310`. Para uso normal, mantenha as portas iguais. Para diagnóstico nessa porta alternativa, um GET com cabeçalho `Host: localhost:4310` testa o encaminhamento. O script não reconfigura a origem para portas alternativas.

O status mostra os containers, a saúde, a política de reinício, a porta e uma resposta HTTP. Alguns serviços auxiliares não têm healthcheck: nesses casos, o resultado esperado é `running` e `sem healthcheck`. Os demais devem estar `healthy`. `unless-stopped` faz voltar com o Docker, exceto após parada explícita. Não reinicie o Docker só para testar isso num servidor compartilhado.

## 4. Fazer o onboarding com sua conta

Esta etapa é sua. Abra o Nod pelo túnel, informe o token e escolha o modelo em **Models**. Instalar o servidor não exige chave de modelo.

Para usar sua assinatura ChatGPT, a documentação do Nod orienta:

1. Escolha **OpenAI → Sign in with ChatGPT**.
2. Entre com sua conta na aba aberta e autorize o Nod.
3. Se o navegador terminar numa página que não carrega, copie **o endereço completo dessa página**.
4. Volte ao Nod, cole em **Callback URL** e selecione **Complete sign-in**.

Esse é o *remote callback*. O login escuta na porta 1455 onde o servidor Nod roda. No seu computador, o endereço final pode não abrir. Colar a URL completa permite que o servidor valide o retorno e guarde a conexão. **Não abra a porta 1455 na internet.** Não compartilhe a URL de callback.

A doc consultada informa suporte a ChatGPT Plus/Pro e possível autorização do administrador em contas gerenciadas. Confira a tela de consentimento da sua conta. Este kit não realiza login nem cadastra chaves por você. Depois escolha o modelo disponível e revise permissões e consumo.

## 5. Ligar Telegram sem domínio

Em **Channels**, escolha Telegram e siga a configuração mostrada pelo Nod. Crie seu bot no BotFather, informe o token no formulário privado e conclua o vínculo pedido pelo aplicativo. Deixe as variáveis de canal vazias no `.env` se quiser configurar pela interface.

Use **polling**. O Nod consulta o Telegram por conexão de saída. Isso funciona sem domínio público e com a porta do Nod privada. Webhook é outra configuração e exige HTTPS público. Não publique o token do bot. Telegram, web e desktop usam o mesmo assistente. Login e pagamentos continuam na interface privada.

## 6. Logs, backup e atualização

```bash
bash ferramentas/nod_vps.sh logs usuario@servidor.example --chave ~/.ssh/chave_vps
bash ferramentas/nod_vps.sh backup usuario@servidor.example --chave ~/.ssh/chave_vps
```

`logs` mostra as últimas 100 linhas do serviço `server`. Filtra valores conhecidos do `.env` e tokens Bearer. Não grava arquivo. Isso não garante remoção de todo dado pessoal ou segredo fornecido durante conversas; revise antes de compartilhar.

Espere terminar as tarefas ativas antes do backup. O script oficial pausa temporariamente os serviços do Nod que copia e retoma os que estavam ligados. A pasta nova fica **na VPS**, ao lado do checkout, por exemplo `/opt/nod-backup-DATA-PID`. Tem acesso restrito. O script exige o marcador `complete`.

O backup inclui `.env`, `postgres.dump`, `server-data.tar.gz`, `workspace-data.tar.gz`, `workspace-tools.tar.gz`, `browser-data.tar.gz`, `source-commit` e `complete`. Contém segredos. Guarde-o cifrado e com acesso restrito fora do servidor, seguindo a política da sua organização. O script não transfere nem cifra o backup automaticamente. Preserve a Vault key original; só o banco não recupera as credenciais.

Leia as notas da revisão escolhida. Use um commit completo ou tag que você conferiu:

```bash
bash ferramentas/nod_vps.sh atualizar usuario@servidor.example --chave ~/.ssh/chave_vps --ref COMMIT_OU_TAG
```

O script busca a revisão e resolve seu commit. Faz backup **antes** de parar a stack e trocar o código. Depois executa setup, valida o bind privado e reconstrói. Não muda o nome do projeto nem apaga volumes. Se falhar, para com erro. Não tente voltar só o código após uma migração de banco.

Para recuperar, siga [server-operations](https://nod.n8n.io/docs/deploy/server-operations/): clone numa pasta nova, selecione o commit de `source-commit` e rode `restore.sh` com o backup e um novo nome de projeto. **Não rode setup antes do restore.** Pare o original antes de iniciar a cópia, evitando rotinas e bots duplicados. Confira histórico, arquivos, credenciais pelo formulário privado, canais e schedules. Restore não foi automatizado neste kit.

## 7. Desligar e voltar

```bash
bash ferramentas/nod_vps.sh parar usuario@servidor.example --chave ~/.ssh/chave_vps
```

Isso usa `docker compose stop` só na instalação indicada. Preserva os volumes. Para voltar, execute `instalar` com as mesmas opções; a configuração existente é preservada. Não use `docker compose down --volumes` para atualizar.

## 8. Quando vale colocar domínio e HTTPS

Vale quando você quer abrir sem túnel ou usar integrações que exigem webhook público. Para uso pessoal por SSH e Telegram polling, não é necessário.

A seção **Add public HTTPS** da documentação pede DNS apontado ao servidor e entrada TCP 80/443. No `.env`, define-se `NOD_PUBLIC_URL=https://nod.example.com`, sem caminho ou parâmetros. Depois, na instalação oficial:

```bash
docker compose --profile https up -d --build --wait
```

O Caddy obtém e renova o certificado. Mantenha `--profile https` nas operações seguintes. Se já existe nginx ou outro proxy ocupando essas portas, planeje a integração com ele; não suba um segundo proxy nas mesmas portas. Preserve Host, WebSockets e streaming e mantenha o backend em loopback.

**Este script atende à instalação privada por túnel.** Não gerencia o perfil HTTPS nem altera nginx, certbot ou firewall. Ao migrar para HTTPS, opere pela documentação oficial, incluindo o perfil nos backups e demais operações. Banco, browser, workspace e conexão Docker continuam privados.

## Fontes e testes

Base: arquivos oficiais `deploy/self-host.mdx`, `deploy/configuration.md`, `deploy/server-operations.md`, `deploy/troubleshooting.md` e `connect/models.mdx` do Nod.

- [Instalação e HTTPS](https://nod.n8n.io/docs/deploy/self-host/)
- [Configuração](https://nod.n8n.io/docs/deploy/configuration/)
- [Modelos e callback remoto](https://nod.n8n.io/docs/connect/models/)
- [Checklist](checklists/servidor-24h.md)

```bash
bash ferramentas/test_nod_vps.sh
```

O teste valida parsing, ajuda, rejeição de argumentos perigosos, plano de atualização e restrição do token. Substitui SSH por um comando que falha se chamado. Não testa uma instalação Docker completa.
