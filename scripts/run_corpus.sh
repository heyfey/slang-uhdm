#!/usr/bin/env bash
# run_corpus.sh [corpus-root] [results.csv]
# Runs converge.sh over every test dir containing dut.sv, classifies results.
# Classes: PASS_CMP > PASS_DUMP > DIFF > UNSUPPORTED > CRASH > SURELOG_FAIL
set -u

CORPUS=${1:-$HOME/git-repos/uhdm2rtlil/test}
OUT=${2:-results.csv}
SCRIPT_DIR=$(dirname "$(realpath "$0")")

echo "test,class,detail" > "$OUT"
declare -A counts
for d in "$CORPUS"/*/; do
    name=$(basename "$d")
    dut="$d/dut.sv"
    [ -f "$dut" ] || continue
    work=$(mktemp -d /tmp/uhdm-corpus.XXXXXX)
    res=$(WORK="$work" "$SCRIPT_DIR/converge.sh" "$dut" 2>/dev/null)
    if grep -q "PASS_CMP" <<<"$res"; then cls=PASS_CMP
    elif grep -q "DUMP_MATCH" <<<"$res"; then cls=PASS_DUMP
    elif grep -q "UNSUPPORTED" <<<"$res"; then cls=UNSUPPORTED
    elif grep -q "DUMP_DIFF" <<<"$res"; then cls=DIFF
    elif grep -q "SURELOG" <<<"$res"; then cls=SURELOG_FAIL
    else cls=CRASH
    fi
    detail=$(grep -E "DUMP_DIFF|UNSUPPORTED" <<<"$res" | head -1 | tr ',' ';')
    echo "$name,$cls,$detail" >> "$OUT"
    counts[$cls]=$(( ${counts[$cls]:-0} + 1 ))
    # keep workdirs only for failures under investigation; clean passes
    case $cls in PASS_CMP|PASS_DUMP|SURELOG_FAIL) rm -rf "$work" ;; esac
done

echo "== scoreboard =="
for k in PASS_CMP PASS_DUMP DIFF UNSUPPORTED CRASH SURELOG_FAIL; do
    echo "$k: ${counts[$k]:-0}"
done
