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
    if grep -q "DUMP_MATCH" <<<"$res" && grep -q "PASS_CMP" <<<"$res"; then cls=PASS
    elif grep -q "DUMP_MATCH" <<<"$res"; then cls=DUMP_ONLY
    elif grep -q "PASS_CMP" <<<"$res" && grep -q "DUMP_DIFF" <<<"$res"; then cls=CMP_ONLY
    elif grep -q "UNSUPPORTED" <<<"$res"; then cls=UNSUPPORTED
    elif grep -q "DUMP_DIFF" <<<"$res"; then cls=DIFF
    elif grep -q "SURELOG" <<<"$res"; then cls=SURELOG_FAIL
    elif grep -q "SLANG_FAIL" <<<"$res"; then cls=SLANG_REJECT
    else cls=CRASH
    fi
    detail=$(grep -E "DUMP_DIFF|statement kind|expression kind|timing control|port kind|binary op|unary op" <<<"$res" | head -2 | tr ',\n' '; ' )
    echo "$name,$cls,$detail" >> "$OUT"
    counts[$cls]=$(( ${counts[$cls]:-0} + 1 ))
    rm -rf "$work"
done

echo "== scoreboard =="
for k in PASS DUMP_ONLY CMP_ONLY DIFF UNSUPPORTED CRASH SLANG_REJECT SURELOG_FAIL; do
    echo "$k: ${counts[$k]:-0}"
done
