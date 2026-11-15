#!/usr/bin/env bash
# Só leitura. Base: FATOS.md F07–F08 e deploy/self-host.mdx do clone oficial.
# Não executa Docker ou Compose. Consulte as limitações no README.md.
set -u
export LC_ALL=C
missing=0
check() {
    local label=$1 value=$2
    shift 2
    if "$@"; then
        printf 'OK %s: %s\n' "$label" "$value"
    else
        printf 'FALTA %s: %s\n' "$label" "$value"
        missing=$((missing + 1))
    fi
}
# Valida antes da comparação; não interpreta entradas como expressões Bash.
at_least() {
    [[ $1 =~ ^[0-9]+$ ]] || return 1
    awk -v actual="$1" -v minimum="$2" 'BEGIN {exit !(actual >= minimum)}'
}
architecture_ok() {
    case "$1" in x86_64|amd64|aarch64|arm64) return 0;; *) return 1;; esac
}
version_major() {
    local value=${1#*:}
    if [[ $value =~ ^v?([0-9]+)\. ]]; then printf '%s' "${BASH_REMATCH[1]}"; fi
}
docker_ok() { at_least "$(version_major "$1")" 25; }
compose_ok() { local m; m=$(version_major "$1"); [[ $m =~ ^[0-9]+$ ]] && (( m >= 2 )); }
present() { [[ $1 == 1 ]]; }
# Só consulta bancos de pacotes locais; não atualiza índices nem executa serviços.
package_version() {
    local package result
    for package in "$@"; do
        if command -v dpkg-query >/dev/null 2>&1; then
            result=$(dpkg-query -W -f='${db:Status-Status} ${Version}' "$package" 2>/dev/null) || result=''
            if [[ $result == installed\ * ]]; then
                printf '%s' "${result#installed }"; return 0
            fi
        elif command -v rpm >/dev/null 2>&1; then
            result=$(rpm -q --qf '%{VERSION}' "$package" 2>/dev/null) || result=''
            if [[ -n $result ]]; then printf '%s' "$result"; return 0; fi
        fi
    done
    return 1
}
if [[ ${CHECAR_FAKE:-0} == 1 ]]; then
    # Modo isolado: variáveis ausentes falham, sem consultar recursos reais.
    arch=${CHECAR_FAKE_ARCH:-desconhecida}
    cores=${CHECAR_FAKE_CORES:-0}
    mem=${CHECAR_FAKE_MEM_BYTES:-0}
    disk=${CHECAR_FAKE_DISK_BYTES:-0}
    docker_version=${CHECAR_FAKE_DOCKER_VERSION:-desconhecida}
    compose_version=${CHECAR_FAKE_COMPOSE_VERSION:-desconhecida}
    openssl_found=${CHECAR_FAKE_OPENSSL:-0}
    hash_found=${CHECAR_FAKE_HASH:-0}
else
    arch=$(uname -m 2>/dev/null) || arch=desconhecida
    cores=$(getconf _NPROCESSORS_ONLN 2>/dev/null) || cores=0
    mem=0
    if [[ -r /proc/meminfo ]]; then
        mem=$(awk '/^MemTotal:/ {printf "%.0f", $2 * 1024}' /proc/meminfo)
    elif [[ $(uname -s) == Darwin ]]; then
        mem=$(sysctl -n hw.memsize 2>/dev/null) || mem=0
    fi
    disk=$(df -Pk . 2>/dev/null | awk 'NR==2 {printf "%.0f", $4 * 1024}')
    docker_version=desconhecida
    compose_version=desconhecida
    if command -v docker >/dev/null 2>&1; then
        docker_version=$(package_version docker-ce docker.io moby-engine) || docker_version=desconhecida
        compose_version=$(package_version docker-compose-plugin docker-compose-v2 docker-compose) || compose_version=desconhecida
    fi
    openssl_found=0
    hash_found=0
    if command -v openssl >/dev/null 2>&1; then openssl_found=1; fi
    if command -v sha256sum >/dev/null 2>&1 || command -v shasum >/dev/null 2>&1; then hash_found=1; fi
fi
check 'arquitetura (AMD64/ARM64)' "$arch" architecture_ok "$arch"
check 'núcleos (mínimo 2)' "$cores" at_least "$cores" 2
check 'memória (mínimo 8 GB, bytes)' "$mem" at_least "$mem" 8000000000
check 'disco livre aqui (mínimo 50 GB, bytes)' "$disk" at_least "$disk" 50000000000
check 'Docker (mínimo 25; pacote)' "$docker_version" docker_ok "$docker_version"
check 'Compose (v2 ou mais novo; pacote)' "$compose_version" compose_ok "$compose_version"
check 'openssl (comando presente)' "$openssl_found" present "$openssl_found"
check 'sha256sum/shasum (comando presente)' "$hash_found" present "$hash_found"
if (( missing == 0 )); then
    printf 'PRONTO\n'
else
    printf 'FALTA %s item(ns)\n' "$missing"
    exit 1
fi
