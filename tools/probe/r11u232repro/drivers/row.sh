#!/bin/bash
# (r11u232) row.sh <corpus> <mode> <name> <binary> <scratch>: run one corpus row-mode with verify_golden.py (--filter
# on the exact name), print the csv row and the golden / ours database paths. Refuses a fenced name (FENCED from
# drivers/env.sh, word boundary) and runs nothing without it.
set -u
[ "$(echo ${FENCED:-} | wc -w)" = 4 ] || { echo "row.sh: source drivers/env.sh" >&2; exit 2; }
C=$1; M=$2; N=$3; B=$4; W=$5/$(basename $B)_$C
for f in $FENCED; do echo "$N" | grep -qw -- "$f" && { echo "row.sh: fenced name refused" >&2; exit 2; }; done
[ -x "$B" ] || { echo "row.sh: binary not executable" >&2; exit 2; }
HERE=$(cd "$(dirname "$0")" && pwd); cd "$HERE/../../../.."
SLANG_UHDM=$B python3 scripts/verify_golden.py --corpus $C --mode $M --jobs 1 --filter "^${N}\$" --out $W/$N.$M.csv --workdir $W >/dev/null 2>&1
tail -1 $W/$N.$M.csv
d=$(ls -d $W/$M/${N}-* | head -1)
g=$(grep -o 'golden cache hit [^)]*' $d/cmds.txt | awk '{print $4}')
echo "GOLDEN $g/golden.uhdm"; echo "OURS $d/slang.uhdm"
