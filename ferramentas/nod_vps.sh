#!/usr/bin/env bash
# Cliente SSH e executor remoto. Nenhuma credencial passa pela linha de comando.
set -euo pipefail
fail() { printf 'ERRO: %s\n' "$*" >&2; exit 1; }
help() {
 cat <<'HELP'
Uso: nod_vps.sh COMANDO usuario@host [opções]
Comandos: instalar, status, tunel, token, logs, parar, atualizar, backup
Opções comuns:
  --chave ARQUIVO   Chave SSH (senão, usa agente/configuração SSH)
  --porta NUMERO    Porta remota (padrão: 4310)
  --pasta CAMINHO   Checkout remoto absoluto (padrão: /opt/nod)
  --local NUMERO    Porta local, apenas tunel (padrão: mesma porta remota)
  --ref REVISAO     Commit/tag, apenas atualizar (obrigatório)
  --help           Esta ajuda
NOD_VPS_DRY=1: mostra o plano e comando SSH, sem conectar nem ler token.
Requer Bash e SSH local; Linux, Docker >=25, Compose >=2, Buildx,
Git, Python 3, OpenSSL, hash, curl, ss, flock, nice e timeout no servidor.
Não instala dependências. Usuário remoto precisa usar Docker e escrever na pasta.
Build: timeout de 90 minutos, nice 10; sem retry automático.
Backup fica ao lado do checkout, em pasta privada com data e PID.
Token: somente terminal interativo; não redirecione nem grave a sessão.
Túnel fica em primeiro plano; Ctrl+C fecha somente o túnel.
HELP
}
remote() {
 local action=$1 folder=$2 port=$3 revision=$4
 export LC_ALL=C
 umask 077
 check_requirements() {
  local cmd arch mem disk cores dv cv available
  for cmd in docker git python3 openssl timeout nice curl ss flock; do command -v "$cmd" >/dev/null || fail "Falta $cmd no servidor."; done
  command -v sha256sum >/dev/null || command -v shasum >/dev/null || fail 'Falta sha256sum/shasum.'
  arch=$(uname -m); case "$arch" in x86_64|aarch64|arm64|amd64) ;; *) fail 'Arquitetura incompatível.';; esac
  cores=$(getconf _NPROCESSORS_ONLN)
  mem=$(awk '/^MemTotal:/ {printf "%.0f", $2*1024}' /proc/meminfo)
  available=$(awk '/^MemAvailable:/ {printf "%.0f", $2*1024}' /proc/meminfo)
  local ancestor=$folder
  while [[ ! -d $ancestor ]]; do ancestor=$(dirname "$ancestor"); done
  disk=$(df -Pk "$ancestor" | awk 'NR==2 {printf "%.0f",$4*1024}')
  (( cores >= 2 && mem >= 8000000000 && disk >= 50000000000 )) || fail 'Precisa de 2 núcleos, 8 GB RAM e 50 GB livres.'
  (( available >= 2000000000 )) || fail 'Menos de 2 GB de RAM disponível. Pare e revise a capacidade.'
  dv=$(docker version --format '{{.Server.Version}}'); cv=$(docker compose version --short)
  [[ $dv =~ ^([0-9]+)\. ]] && (( BASH_REMATCH[1] >= 25 )) || fail 'Docker >=25 necessário.'
  [[ $cv =~ ^v?([0-9]+)\. ]] && (( BASH_REMATCH[1] >= 2 )) || fail 'Compose >=2 necessário.'
  [[ $(docker info --format '{{.OSType}}') == linux ]] || fail 'Docker precisa usar containers Linux.'
  docker buildx version >/dev/null || fail 'Instale o plugin Buildx antes de continuar.'
  printf 'Requisitos OK: %s núcleos; RAM %s bytes; disponível %s; disco livre %s.\n' "$cores" "$mem" "$available" "$disk"
 }
 redact() {
  python3 -u -c 'import sys,re,pathlib
p=pathlib.Path(".env")
values=[x.split("=",1)[1].strip().strip("\"\x27") for x in p.read_text().splitlines() if "=" in x and not x.startswith("#")] if p.exists() else []
values=sorted([v for v in values if len(v)>=8],key=len,reverse=True)
for line in sys.stdin:
 for value in values: line=line.replace(value,"[OCULTO]")
 line=re.sub(r"(?i)(bearer\s+)[A-Za-z0-9._~+/=-]+",r"\1[OCULTO]",line)
 sys.stdout.write(line)'
 }
 private_config() {
  python3 - "$port" <<'PY'
from pathlib import Path
import sys
p=Path('.env'); lines=p.read_text().splitlines()
for key,value in {'NOD_BIND_ADDRESS':'127.0.0.1','PORT':sys.argv[1]}.items():
    lines=[s for s in lines if not s.startswith(key+'=')]
    lines.insert(0,key+'='+value)
p.write_text('\n'.join(lines)+'\n'); p.chmod(0o600)
PY
 }
 validate_config() {
  docker compose config --format json | python3 -c 'import json,sys
c=json.load(sys.stdin)
s=c["services"]["server"]
port=str(s["environment"]["PORT"])
if s["environment"]["NOD_PUBLIC_URL"] != "http://localhost:"+port:
 sys.exit("ERRO: origin inesperada; este script exige instalação privada em http://localhost:PORT.")
for name,s in c["services"].items():
 for p in s.get("ports",[]):
  if p.get("host_ip")!="127.0.0.1": sys.exit("ERRO: porta fora do loopback; operação recusada.")
 if s.get("restart")!="unless-stopped": sys.exit("ERRO: restart policy inesperada.")
print("Configuração OK: portas privadas e restart unless-stopped.")'
 }
 health() {
  docker compose ps -a
  local ids id bad=0
  ids=$(docker compose ps -aq)
  [[ -n $ids ]] || fail 'Nenhum container Nod encontrado.'
  local expected actual
  expected=$(docker compose config --services | sort)
  actual=$(docker compose ps --services --status running | sort)
  [[ $expected == "$actual" ]] || bad=1
  for id in $ids; do
   docker inspect --format '{{.Name}} estado={{.State.Status}} saúde={{if .State.Health}}{{.State.Health.Status}}{{else}}sem healthcheck{{end}} restart={{.HostConfig.RestartPolicy.Name}}' "$id"
   [[ $(docker inspect --format '{{.State.Running}} {{if .State.Health}}{{.State.Health.Status}}{{else}}healthy{{end}}' "$id") == 'true healthy' ]] || bad=1
  done
  ss -ltn "sport = :$port"
  curl --fail --silent --show-error --max-time 15 -o /dev/null -w 'HTTP %{http_code}\n' -H "Host: localhost:$port" "http://127.0.0.1:$port/"
  (( bad == 0 )) || fail 'Há container parado ou sem saúde.'
 }
 backup() {
  local dest="${folder}-backup-$(date -u +%Y%m%dT%H%M%SZ)-$$"
  printf 'Backup privado na VPS: %s. Pausa temporária apenas do Nod.\n' "$dest"
  timeout --kill-after=30s 90m sh backup.sh "$dest" 2>&1 | redact
  [[ -f $dest/complete ]] || fail 'Backup não foi concluído.'
 }
 build() {
  local start=$SECONDS result=0
  validate_config
  nice -n 10 timeout --kill-after=30s 90m docker compose up -d --build --wait 2>&1 | redact || result=$?
  printf 'Build e inicialização: %s segundos; código %s.\n' "$((SECONDS-start))" "$result"
  (( result == 0 )) || fail 'Build falhou. Não há retry automático. Após duas falhas, pare; não apague recursos.'
  health
 }
 if [[ $action == instalar || $action == atualizar ]]; then check_requirements; fi
 if [[ $action == instalar ]]; then
  if [[ -e $folder ]]; then
   [[ -d $folder/.git ]] || fail 'Pasta existente não é checkout Git.'
  else
   [[ -z $(ss -H -ltn "sport = :$port") ]] || fail 'Porta ocupada.'
   git clone https://github.com/n8n-io/nod.git "$folder"
  fi
 fi
 cd "$folder/deployment/self-host" || fail 'Instalação não encontrada.'
 case "$action" in instalar|atualizar|backup|parar)
  exec 9>.nod-vps.lock
  flock -n 9 || fail 'Outra operação Nod está em andamento.';; esac
 case "$action" in
 instalar)
  # Não atualiza uma instalação ativa sem backup.
  if [[ -f .env ]]; then
   printf 'Configuração existente: preservada. Para mudar revisão, use atualizar --ref.\n'
  else
   [[ -z $(git status --porcelain --untracked-files=no) ]] || fail 'Checkout alterado.'
   git pull --ff-only
  fi
  sh setup.sh 2>&1 | redact
  private_config; build;;
 atualizar)
  [[ -z $(git status --porcelain --untracked-files=no) ]] || fail 'Checkout alterado; revise antes de atualizar.'
  git fetch origin --tags
  local target
  target=$(git rev-parse --verify "${revision}^{commit}")
  validate_config; backup
  docker compose stop
  git checkout --detach "$target"
  sh setup.sh 2>&1 | redact
  private_config; build;;
 status) validate_config; health;;
 backup) validate_config; backup;;
 parar) docker compose stop;;
 logs) docker compose logs --no-color --tail 100 server 2>&1 | redact;;
 token)
  python3 -c 'from pathlib import Path
for line in Path(".env").read_text().splitlines():
 if line.startswith("NOD_AUTH_TOKEN="): print(line.split("=",1)[1]); break
else: raise SystemExit("Token não encontrado.")';;
 esac
}
# Entrada interna; SSH recebe ambiente limpo, sem overrides de Compose/segredos.
if [[ ${1:-} == __remote ]]; then
 [[ ${NOD_VPS_REMOTE:-0} == 1 && ${NOD_VPS_DRY:-0} != 1 ]] || fail 'Entrada interna reservada ao SSH.'
 shift; remote "$@"; exit
fi
[[ $# -gt 0 ]] || { help; exit 1; }
[[ $1 != --help ]] || { help; exit; }
action=$1; shift
case "$action" in instalar|status|tunel|token|logs|parar|atualizar|backup) ;; *) fail 'Subcomando desconhecido. Use --help.';; esac
[[ ${1:-} != --help ]] || { help; exit; }
[[ $# -gt 0 ]] || fail 'Informe usuario@host.'
host=$1; shift
[[ $host =~ ^[a-zA-Z0-9_][a-zA-Z0-9_.-]*@[a-zA-Z0-9][a-zA-Z0-9.-]*$ ]] || fail 'Use usuario@host (DNS ou IPv4).'
key=''; port=4310; folder=/opt/nod; local_port=''; revision=''
while (( $# )); do
 case "$1" in
 --help) help; exit;;
 --chave|--porta|--pasta|--local|--ref)
  [[ $# -ge 2 && -n $2 && $2 != --* ]] || fail "Falta valor para $1."
  case "$1" in --chave) key=$2;; --porta) port=$2;; --pasta) folder=$2;; --local) local_port=$2;; --ref) revision=$2;; esac
  shift 2;;
 *) fail "Opção desconhecida: $1";;
 esac
done
valid_port() { [[ $1 =~ ^[0-9]{1,5}$ ]] && (( 10#$1 >= 1 && 10#$1 <= 65535 )); }
valid_port "$port" || fail 'Porta inválida (1–65535).'
port=$((10#$port))
[[ $folder =~ ^/[a-zA-Z0-9_./-]+$ && $folder != / && $folder != */../* && $folder != */.. ]] || fail 'Pasta absoluta inválida; use caminho sem espaços ou metacaracteres.'
folder=${folder%/}
if [[ -n $local_port ]]; then [[ $action == tunel ]] || fail '--local só vale para tunel.'; valid_port "$local_port" || fail 'Porta local inválida.'; fi
local_port=${local_port:-$port}; local_port=$((10#$local_port))
if [[ $action == atualizar ]]; then
 [[ $revision =~ ^[a-zA-Z0-9][a-zA-Z0-9._/-]*$ ]] || fail 'atualizar exige --ref COMMIT-ou-TAG.'
else [[ -z $revision ]] || fail '--ref só vale para atualizar.'; fi
ssh_args=(-o BatchMode=yes -o ConnectTimeout=15 -o ServerAliveInterval=30 -o ServerAliveCountMax=3)
if [[ -n $key ]]; then
 [[ ${NOD_VPS_DRY:-0} == 1 || -r $key ]] || fail 'Chave SSH não pode ser lida.'
 ssh_args+=(-i "$key")
fi
if [[ $action == tunel ]]; then
 printf 'Abra http://localhost:%s e mantenha este terminal aberto. Ctrl+C fecha o túnel.\n' "$local_port"
 [[ $local_port == "$port" ]] || printf 'ATENÇÃO: porta alternativa exige NOD_PUBLIC_URL compatível; o Host diferente é recusado. Para uso normal, mantenha as portas iguais.\n'
 command_args=(ssh "${ssh_args[@]}" -o ExitOnForwardFailure=yes -N -L "127.0.0.1:$local_port:127.0.0.1:$port" "$host")
else
 printf -v remote_args '%q ' __remote "$action" "$folder" "$port" "$revision"
 command_args=(ssh "${ssh_args[@]}" "$host" "env -i NOD_VPS_REMOTE=1 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin bash -s -- $remote_args")
fi
if [[ ${NOD_VPS_DRY:-0} == 1 ]]; then
 printf 'DRY: ação=%s pasta=%s porta=%s ref=%s\n' "$action" "$folder" "$port" "$revision"
 case "$action" in
 instalar) echo 'Plano: requisitos; git clone/pull --ff-only; sh setup.sh; NOD_BIND_ADDRESS=127.0.0.1; nice timeout 90m docker compose up -d --build --wait; saúde';;
 atualizar) echo 'Plano: requisitos; fetch/ref; sh backup.sh; complete; docker compose stop; checkout; setup; bind privado; build --wait';;
 backup) echo 'Plano: sh backup.sh CAMINHO-NOVO; conferir complete';;
 token) echo 'Plano: mostrar NOD_AUTH_TOKEN somente no terminal, nunca arquivo';;
 esac
 printf '%q ' "${command_args[@]}"; printf '\n'; exit
fi
if [[ $action == token ]]; then
 [[ -t 1 ]] || fail 'Token só pode ser mostrado em terminal interativo.'
 printf 'ATENÇÃO: o token dá acesso completo. Não grave nem compartilhe esta tela.\n' >&2
fi
if [[ $action == tunel ]]; then exec "${command_args[@]}"; fi
"${command_args[@]}" < "$0"
