#!/usr/bin/env bash
# r10oth4 -- dump a golden/ours pair into one workdir so the head can be decoded
# by ancestor walk.  Takes the ours database path and the golden path.
#   usage: ./headdump.sh <ours.uhdm> <golden.uhdm> <workdir>
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
set -u
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
O=$1; G=$2; D=$3
[ -f "$O" ] || { echo NO_OURS; exit 6; }
[ -f "$G" ] || { echo NO_GOLDEN; exit 6; }
mkdir -p "$D" || exit 9
"$DUMP" "$G" 2>/dev/null | sed '1d' > "$D/g.dump"
"$DUMP" "$O" 2>/dev/null | sed '1d' > "$D/o.dump"
"$CMP" "$G" "$O" > "$D/cmp.log" 2>&1 && echo PASS_CMP || echo CMP_FAIL
echo "cmp lines=$(wc -l < "$D/cmp.log") heads(^LHS: col 0)=$(grep -c '^LHS:' "$D/cmp.log")"
echo "g.dump=$(wc -l < "$D/g.dump")  o.dump=$(wc -l < "$D/o.dump")"
diff -u "$D/g.dump" "$D/o.dump" > "$D/d.diff"
echo "DUMP_DIFF content=$(( $(grep -c '^[-+]' "$D/d.diff") - 2 ))  hunks=$(grep -c '^@@' "$D/d.diff")"
echo "WD=$D"
