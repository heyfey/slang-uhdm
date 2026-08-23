#!/usr/bin/env bash
# Reuse the frozen r10uvm102 boundary source universe and pristine arms.
set -u

ROOT=${1:?prior boundary root}
BIN=${2:?ship-candidate binary}
KIND=${3:?F or D}
JOBS=${JOBS:-20}
OUT=${4:-$ROOT/ship_${KIND}.txt}
UHDM_DUMP=${UHDM_DUMP:-uhdm-dump}
PRIS_BIN=${PRIS_BIN:-}

run_dir() {
    d=$1
    bin=$2
    dump=$3
    for mode in def elab; do
        opt=()
        [ "$mode" = elab ] && opt=(--elabuhdm)
        db="$d/ship_${mode}.uhdm"
        log="$d/ship_${mode}.log"
        out="$d/ship_${mode}.dump"
        (cd "$d" && shopt -s nullglob && src=(./*.sv ./*.v) &&
            "$bin" "${src[@]}" "${opt[@]}" -o "$db" >"$log" 2>&1)
        rc=$?
        printf '%s\n' "$rc" >"$d/ship_${mode}.rc"
        ref=pris
        if [ -n "${PRIS_BIN:-}" ]; then
            ref=fresh_pris
            pdb="$d/${ref}_${mode}.uhdm"
            plog="$d/${ref}_${mode}.log"
            (cd "$d" && shopt -s nullglob && src=(./*.sv ./*.v) &&
                "$PRIS_BIN" "${src[@]}" "${opt[@]}" -o "$pdb" >"$plog" 2>&1)
            prc=$?
            printf '%s\n' "$prc" >"$d/${ref}_${mode}.rc"
            if [ -f "$pdb" ]; then
                "$dump" "$pdb" 2>/dev/null | sed '1d' >"$d/${ref}_${mode}.dump"
            fi
            rm -f "$pdb"
        fi
        oldrc=$(cat "$d/${ref}_${mode}.rc")
        old=0; new=0
        [ -f "$d/${ref}_${mode}.dump" ] && old=1
        if [ -f "$db" ]; then
            "$dump" "$db" 2>/dev/null | sed '1d' >"$out"
            new=1
        fi
        rm -f "$db"
        verdict=IDENTICAL
        if [ "$rc" != "$oldrc" ]; then
            verdict=RC_DIFF
        elif [ "$old" != "$new" ]; then
            verdict=ASYM
        elif [ "$old" = 0 ]; then
            verdict=NO_OUTPUT
        elif ! cmp -s "$d/${ref}_${mode}.dump" "$out"; then
            verdict=MOVED
        fi
        printf '%s\t%s\t%s\n' "$verdict" "$mode" "$(basename "$d")"
    done
}
export -f run_dir
export PRIS_BIN

find "$ROOT" -mindepth 1 -maxdepth 1 -type d -name "${KIND}*" -print0 |
    sort -z |
    xargs -0 -P "$JOBS" -n 1 bash -c 'run_dir "$3" "$1" "$2"' _ \
        "$BIN" "$UHDM_DUMP" >"$OUT"

listed=$(find "$ROOT" -mindepth 1 -maxdepth 1 -type d -name "${KIND}*" | wc -l)
processed=$(wc -l <"$OUT")
printf 'DIRS=%s ARMS=%s IDENTICAL=%s MOVED=%s NO_OUTPUT=%s RC_DIFF=%s ASYM=%s\n' \
    "$listed" "$processed" \
    "$(grep -c '^IDENTICAL' "$OUT" || true)" \
    "$(grep -c '^MOVED' "$OUT" || true)" \
    "$(grep -c '^NO_OUTPUT' "$OUT" || true)" \
    "$(grep -c '^RC_DIFF' "$OUT" || true)" \
    "$(grep -c '^ASYM' "$OUT" || true)"
grep '^MOVED' "$OUT" || true
