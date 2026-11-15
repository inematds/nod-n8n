#!/usr/bin/env bash
set -euo pipefail
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
script="$script_dir/checar_servidor.sh"
tests=0
run_case() {
    local name=$1 expected_missing=$2 output status=0 last count_ok count_missing
    shift 2
    output=$(env CHECAR_FAKE=1 CHECAR_FAKE_ARCH=x86_64 CHECAR_FAKE_CORES=2 \
        CHECAR_FAKE_MEM_BYTES=8000000000 CHECAR_FAKE_DISK_BYTES=50000000000 \
        CHECAR_FAKE_DOCKER_VERSION=25.0.0 CHECAR_FAKE_COMPOSE_VERSION=2.0.0 \
        CHECAR_FAKE_OPENSSL=1 CHECAR_FAKE_HASH=1 "$@" bash "$script") || status=$?
    last=${output##*$'\n'}
    count_ok=$(printf '%s\n' "$output" | awk '/^OK / {n++} END {print n+0}')
    count_missing=$(printf '%s\n' "$output" | awk '/^FALTA .*: / {n++} END {print n+0}')
    if (( expected_missing == 0 )); then
        [[ $last == PRONTO && $status == 0 ]] || { printf 'ERRO %s\n%s\n' "$name" "$output"; exit 1; }
    else
        [[ $last == "FALTA $expected_missing item(ns)" && $status == 1 ]] || { printf 'ERRO %s\n%s\n' "$name" "$output"; exit 1; }
    fi
    [[ $count_missing == "$expected_missing" && $count_ok == "$((8 - expected_missing))" ]] || { printf 'ERRO contagem: %s\n' "$name"; exit 1; }
    [[ $(printf '%s\n' "$output" | wc -l) == 9 ]] || { printf 'ERRO linhas: %s\n' "$name"; exit 1; }
    tests=$((tests + 1))
    printf 'OK teste %s: %s\n' "$name" "$last"
}
run_case 'limiares exatos' 0
run_case 'ARM e versão com epoch' 0 CHECAR_FAKE_ARCH=aarch64 CHECAR_FAKE_DOCKER_VERSION=5:28.0.1-1 CHECAR_FAKE_COMPOSE_VERSION=v2.30.0
run_case 'arquitetura incompatível' 1 CHECAR_FAKE_ARCH=armv7l
run_case 'CPU abaixo' 1 CHECAR_FAKE_CORES=1
run_case 'memória abaixo por um byte' 1 CHECAR_FAKE_MEM_BYTES=7999999999
run_case 'disco abaixo por um byte' 1 CHECAR_FAKE_DISK_BYTES=49999999999
run_case 'Docker antigo' 1 CHECAR_FAKE_DOCKER_VERSION=24.0.9
run_case 'Compose v1' 1 CHECAR_FAKE_COMPOSE_VERSION=1.29.2
run_case 'Compose v5 ou mais novo aceito' 0 CHECAR_FAKE_COMPOSE_VERSION=5.2.0
run_case 'openssl ausente' 1 CHECAR_FAKE_OPENSSL=0
run_case 'checksum ausente' 1 CHECAR_FAKE_HASH=0
run_case 'valores desconhecidos' 3 CHECAR_FAKE_MEM_BYTES=indisponivel CHECAR_FAKE_DOCKER_VERSION=desconhecida CHECAR_FAKE_CORES=-2
run_case 'todos ausentes' 8 CHECAR_FAKE_ARCH='' CHECAR_FAKE_CORES='' CHECAR_FAKE_MEM_BYTES='' CHECAR_FAKE_DISK_BYTES='' CHECAR_FAKE_DOCKER_VERSION='' CHECAR_FAKE_COMPOSE_VERSION='' CHECAR_FAKE_OPENSSL=0 CHECAR_FAKE_HASH=0
printf 'PASSOU: %s cenários; PRONTO e FALTA conferidos.\n' "$tests"
