#!/usr/bin/env bash
# triage.sh <results.csv> [corpus-root]
# Clusters UNSUPPORTED tests by full missing-feature set (fast, slang-uhdm
# only) and DIFF tests by first-divergence dump line signature.
set -u
CSV=$1
ROOT=$(cd "$(dirname "$(realpath "$0")")/.." && pwd)
CORPUS=${2:-${UHDM2RTLIL_TESTS:-$ROOT/third_party/uhdm2rtlil/test}}
SLANG_UHDM=${SLANG_UHDM:-$ROOT/build/slang-uhdm}
SCRIPT_DIR=$(dirname "$(realpath "$0")")

echo "=== UNSUPPORTED feature frequency (tests blocked) ==="
for t in $(grep ",UNSUPPORTED," "$CSV" | cut -d, -f1); do
    "$SLANG_UHDM" "$CORPUS/$t/dut.sv" -o /dev/null 2>&1 | grep "^  " | sed 's/^  //'
done | sort | uniq -c | sort -rn | head -30

echo ""
echo "=== DIFF first-divergence signatures ==="
run_diff() {
    t=$1
    W=$(mktemp -d)
    WORK=$W "$SCRIPT_DIR/converge.sh" "$CORPUS/$t/dut.sv" >/dev/null 2>&1
    sig=$(tail -n +3 "$W/dump.diff" 2>/dev/null | grep -m1 '^[-+]' | \
          sed -E 's/line:[0-9]+:[0-9]+//g; s/endln:[0-9]+:[0-9]+//g; s/\(work@[^)]*\)//g; s/work@[^ ,]*//g; s/[0-9]+//g' | cut -c1-60)
    echo "$sig"
    rm -rf "$W"
}
export -f run_diff
export SCRIPT_DIR CORPUS
grep ",DIFF," "$CSV" | cut -d, -f1 | xargs -P "${JOBS:-4}" -I{} bash -c 'run_diff {}' | sort | uniq -c | sort -rn | head -20
