#!/bin/bash
# rowsoff.sh <binary> <workdir> <corpus> <names regex> [ENV=VAL ...]: re-run the named corpus rows (both modes)
# with <binary> under ENV into <workdir>; refuses a regex that could match a fenced name (fail closed).
set -u; B=$1; W=$2; C=$3; RX=$4; shift 4
EX=("$@"); source /tmp/v11u178_env.sh
for n in $FENCED; do echo "$n" | grep -qE "^($RX)$" && { echo "rowsoff: regex matches a fenced name"; exit 3; }; done
export SLANG_UHDM=$B; unset GOLDEN_DEFER
cd /tmp/wt_v11u178 && env "${EX[@]}" python3 scripts/verify_golden.py --corpus $C --mode both --jobs 3 --out $W.csv --workdir $W --filter "^($RX)$" > $W.log 2>&1
echo "rc=$? rows=$(($(wc -l < $W.csv)-1))"
