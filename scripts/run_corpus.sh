#!/usr/bin/env bash
# DEPRECATED as a gate: superseded by scripts/verify_golden.py
#   python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags ...
# which covers the same corpus plus multi-file project.f tests, uses the same
# artifact-based Surelog policy, and carries the dump column (PASS==CMP_EQUAL+
# match, CMP_ONLY==CMP_EQUAL+differ, DIFF==CMP_NOTEQUAL). Kept only to
# reproduce phase-1 CSVs; do not build new gating on it.
# run_corpus.sh [corpus-root] [results.csv] [prev-results.csv]
# Parallel corpus scoreboard. Classes:
#   PASS       dump identical + uhdm-cmp pass
#   DUMP_ONLY  dump identical, cmp fail (invisible-field mismatch)
#   CMP_ONLY   cmp pass, dump differs (usually weakly-tail ordering)
#   DIFF / UNSUPPORTED / CRASH / SLANG_REJECT / SURELOG_FAIL
# With prev-results.csv: exits 1 if any previously PASS/CMP_ONLY test regressed.
set -u

ROOT=$(cd "$(dirname "$(realpath "$0")")/.." && pwd)
CORPUS=${1:-${UHDM2RTLIL_TESTS:-$ROOT/third_party/uhdm2rtlil/test}}
OUT=${2:-results.csv}
PREV=${3:-}
SCRIPT_DIR=$(dirname "$(realpath "$0")")
JOBS=${JOBS:-4}

run_one() {
    d=$1
    name=$(basename "$d")
    dut="$d/dut.sv"
    [ -f "$dut" ] || return 0
    work=$(mktemp -d /tmp/uhdm-corpus.XXXXXX)
    res=$(WORK="$work" "$SCRIPT_DIR/converge.sh" "$dut" 2>/dev/null)
    if grep -q "DUMP_MATCH" <<<"$res" && grep -q "PASS_CMP" <<<"$res"; then cls=PASS
    elif grep -q "DUMP_MATCH" <<<"$res"; then cls=DUMP_ONLY
    elif grep -q "PASS_CMP" <<<"$res" && grep -q "DUMP_DIFF" <<<"$res"; then cls=CMP_ONLY
    elif grep -q "UNSUPPORTED" <<<"$res"; then cls=UNSUPPORTED
    elif grep -q "DUMP_DIFF" <<<"$res"; then cls=DIFF
    elif grep -qE "SURELOG_FAIL|SURELOG_NO_UHDM" <<<"$res"; then cls=SURELOG_FAIL
    elif grep -q "SLANG_FAIL" <<<"$res"; then cls=SLANG_REJECT
    else cls=CRASH
    fi
    detail=$(grep -E "DUMP_DIFF|kind|conversion|form|block|select|typespec" <<<"$res" | head -3 | tr ',\n' '; ')
    echo "$name,$cls,$detail"
    rm -rf "$work"
}
export -f run_one
export SCRIPT_DIR

echo "test,class,detail" > "$OUT"
ls -d "$CORPUS"/*/ | xargs -P "$JOBS" -I{} bash -c 'run_one {}' >> "$OUT"

echo "== scoreboard =="
for k in PASS DUMP_ONLY CMP_ONLY DIFF UNSUPPORTED CRASH SLANG_REJECT SURELOG_FAIL; do
    echo "$k: $(grep -c ",$k," "$OUT" || true)"
done

if [ -n "$PREV" ] && [ -f "$PREV" ]; then
    reg=$(comm -13 <(grep -E ",(PASS|CMP_ONLY)," "$OUT" | cut -d, -f1 | sort) \
                   <(grep -E ",(PASS|CMP_ONLY)," "$PREV" | cut -d, -f1 | sort))
    if [ -n "$reg" ]; then
        echo "== REGRESSIONS vs $PREV =="
        echo "$reg"
        exit 1
    fi
    echo "== no regressions vs $PREV =="
fi
