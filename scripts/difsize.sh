#!/usr/bin/env bash
# For each DIFF test in baseline, run converge.sh and record diff line count
set -u
ROOT=$(cd "$(dirname "$(realpath "$0")")/.." && pwd)
BASE=$ROOT/results/baseline_auto.csv
CORPUS=${UHDM2RTLIL_TESTS:-$ROOT/third_party/uhdm2rtlil/test}
SCRIPT=$ROOT/scripts/converge.sh
run_one() {
    name=$1
    work=$(mktemp -d /tmp/uhdm-difsize.XXXXXX)
    res=$(WORK="$work" "$SCRIPT" "$CORPUS/$name/dut.sv" 2>/dev/null)
    n=$(grep -oP 'DUMP_DIFF \K[0-9]+' <<<"$res" || echo "?")
    echo "$name,$n"
    rm -rf "$work"
}
export -f run_one
export CORPUS SCRIPT
grep ',DIFF,' "$BASE" | cut -d, -f1 | xargs -P 4 -I{} bash -c 'run_one {}' > difsizes.csv
sort -t, -k2 -n difsizes.csv | head -60
