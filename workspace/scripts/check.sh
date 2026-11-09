#!/usr/bin/env bash

set -u
export LC_ALL=C
ulimit -c 0
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
TEMP_DIR="$(mktemp -d)" || exit 2
trap 'rm -rf -- "${TEMP_DIR}"' EXIT
PASSES=0
FAILURES=0

check() {
    local description="$1"
    shift
    if "$@" > /dev/null 2>&1; then
        printf 'PASS: %s\n' "${description}"
        PASSES=$((PASSES + 1))
    else
        printf 'FAIL: %s\n' "${description}"
        FAILURES=$((FAILURES + 1))
    fi
}

is_binary() {
    [[ -f "$1" && -x "$1" ]] || return 1
    [[ "$(file -b -- "$1")" == ELF*executable* ]]
}

matches_tests() {
    local program="$1"
    local input="" expected=""
    local count=0
    is_binary "${program}" || return 1
    for input in "${WORKSPACE}/tests"/test*.in; do
        [[ -f "${input}" ]] || continue
        expected="${input%.in}.expected"
        [[ -f "${expected}" ]] || return 1
        timeout 3 "${program}" < "${input}" > "${TEMP_DIR}/actual.out" 2> "${TEMP_DIR}/actual.err" || return 1
        cmp -s "${expected}" "${TEMP_DIR}/actual.out" || return 1
        [[ ! -s "${TEMP_DIR}/actual.err" ]] || return 1
        count=$((count + 1))
    done
    (( count == TEST_COUNT ))
}

summary() {
    local total=$((PASSES + FAILURES))
    local width="${#total}"
    printf '\n== Resumen ===============================\n\n'
    printf '%-26s %*d\n' 'Comprobaciones exitosas:' "${width}" "${PASSES}"
    printf '%-26s %*d\n\n' 'Comprobaciones pendientes:' "${width}" "${FAILURES}"
    (( FAILURES == 0 ))
}

CODE_DIR="${WORKSPACE}/code"
TEST_COUNT=3

objects_exist() {
    local dir="$1"
    shift
    local object=""
    for object in "$@"; do
        [[ -f "${dir}/${object}.o" ]] || return 1
        [[ "$(file -b -- "${dir}/${object}.o")" == ELF*relocatable* ]] || return 1
    done
}

sources_compile() {
    gcc -Wall -Wextra -Werror -std=c11 -g -O0 \
        "${CODE_DIR}/main.c" "${CODE_DIR}/scanner.c" \
        "${CODE_DIR}/navigation.c" "${CODE_DIR}/report.c" \
        -o "${TEMP_DIR}/reference" || return 1
    matches_tests "${TEMP_DIR}/reference"
}

archive_is_correct() {
    [[ -f "${CODE_DIR}/libnavgrid.a" ]] || return 1
    [[ "$(ar t "${CODE_DIR}/libnavgrid.a" | LC_ALL=C sort)" == $'navigation.o\nreport.o\nscanner.o' ]] || return 1
    gcc "${CODE_DIR}/main.o" -L"${CODE_DIR}" -l:libnavgrid.a -o "${TEMP_DIR}/from_archive" || return 1
    matches_tests "${TEMP_DIR}/from_archive"
}

printf '%s\n' '========================================='
printf '%s\n' '==   Verificación de laboratorio CMO   =='
printf '%s\n' '========================================='
printf '\n== Actividades ==========================\n\n'
check '[1.2] Las fuentes compilan sin warnings y conservan los resultados esperados' sources_compile
check '[2.1] Existen los cuatro archivos objeto en code' objects_exist "${CODE_DIR}" main scanner navigation report
check '[2.2] imperial_nav corresponde a un binario y supera los tres tests' matches_tests "${CODE_DIR}/imperial_nav"
check '[3.1] libnavgrid.a contiene los tres módulos y permite construir el programa' archive_is_correct
check '[3.2] imperial_nav_static corresponde a un binario y supera los tres tests' matches_tests "${CODE_DIR}/imperial_nav_static"
check '[4.1] tests-run.sh tiene permiso de ejecución' test -x "${SCRIPT_DIR}/tests-run.sh"
check '[4.2] check.sh tiene permiso de ejecución' test -x "${SCRIPT_DIR}/check.sh"
summary
