#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
export NOD_VPS_DRY=1
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
# Uma chamada SSH acidental faria qualquer caso positivo falhar.
printf '#!/bin/sh\necho "SSH REAL PROIBIDO NO TESTE" >&2\nexit 98\n' > "$work/ssh"
chmod +x "$work/ssh"
export PATH="$work:$PATH"
count=0
ok() { bash ./nod_vps.sh "$@" > "$work/out" 2>&1 || { cat "$work/out"; exit 1; }; count=$((count+1)); }
bad() { if bash ./nod_vps.sh "$@" > "$work/out" 2>&1; then printf 'Aceitou argumentos inválidos: %s\n' "$*"; exit 1; fi; count=$((count+1)); }
contains() { grep -Fq -- "$1" "$work/out" || { cat "$work/out"; exit 1; }; }
ok --help; contains 'Uso:'
for action in instalar status tunel token logs parar backup; do
 ok "$action" pessoa@servidor.example; contains 'DRY:'
done
ok atualizar pessoa@host --ref v1.2.3; contains 'sh backup.sh'
ok instalar pessoa@host --chave '/tmp/chave com espaços' --porta 54310 --pasta /srv/meu-nod
contains 'porta=54310'; contains 'NOD_BIND_ADDRESS=127.0.0.1'; contains 'timeout 90m'
ok tunel pessoa@host --local 14310; contains '127.0.0.1:14310:127.0.0.1:4310'
ok tunel pessoa@host --porta 04310; contains '127.0.0.1:4310:127.0.0.1:4310'
ok status --help; contains 'Uso:'
bad __remote status /opt/nod 4310 main
bad; bad desconhecido pessoa@host; bad instalar; bad instalar --chave x
bad instalar '-oProxyCommand=x'; bad instalar 'a@host;id'
bad instalar pessoa@host --porta; bad instalar pessoa@host --wat x
for port in 0 65536 -1 1.2 abc '$(id)' 999999999999999999999; do bad instalar pessoa@host --porta "$port"; done
bad instalar pessoa@host --pasta relative; bad instalar pessoa@host --pasta /tmp/../etc
bad instalar pessoa@host --pasta '/tmp/a;id'; bad instalar pessoa@host --pasta /
bad status pessoa@host --local 4310; bad tunel pessoa@host --local 0
bad atualizar pessoa@host; bad atualizar pessoa@host --ref '--upload-pack=x'
bad status pessoa@host --ref main
# Fora do dry, token redirecionado deve falhar ANTES do SSH.
if NOD_VPS_DRY=0 bash ./nod_vps.sh token pessoa@host > "$work/out" 2>&1; then exit 1; fi
contains 'Token só pode ser mostrado'; count=$((count+1))
# Regressão real: executa o editor de .env num diretório isolado.
python3 - "$work" <<'PYTEST'
from pathlib import Path
import re,subprocess,sys
source=Path('nod_vps.sh').read_text()
block=re.search(r"private_config\(\).*?<<'PY'\n(.*?)\nPY", source, re.S).group(1)
p=Path(sys.argv[1])/'.env'
p.write_text('NOD_PUBLIC_URL=http://localhost:${PORT}\nPORT=4310\nNOD_AUTH_TOKEN=exemplo-sem-segredo-real\nNOD_BIND_ADDRESS=0.0.0.0\n')
subprocess.run(['python3','-','54310'],input=block,text=True,cwd=p.parent,check=True)
s=p.read_text()
assert s.index('PORT=54310') < s.index('NOD_PUBLIC_URL=')
assert s.count('PORT=54310') == 1 and 'PORT=4310' not in s
assert 'NOD_BIND_ADDRESS=127.0.0.1' in s and '0.0.0.0' not in s
assert 'NOD_AUTH_TOKEN=exemplo-sem-segredo-real' in s
assert p.stat().st_mode & 0o777 == 0o600
PYTEST
count=$((count+1))
printf 'OK: %s casos; nenhum SSH real.\n' "$count"
