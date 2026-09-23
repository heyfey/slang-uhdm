#!/bin/bash
# calib110.sh <grid-dir> <out-root> — GOLDEN-VS-GOLDEN calibration: a second
# pinned-Surelog run per arm (same flags as grid110.sh), official uhdm-cmp of
# the first golden (<out-root>/<arm>/gold.uhdm) against the second.  Prints
# "<arm> <lines> <heads>" and the nonzero count.
GRID=${1:?grid}; OUT=${2:?out}
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
CMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp
nz=0; n=0
while read -r rel <&3; do
  arm=$(dirname "${rel#./}"); w="$OUT/$arm"; [ -f "$w/gold.uhdm" ] || { echo "$arm NOGOLD"; continue; }
  rm -rf "$w/gold2"; mkdir -p "$w/gold2"
  (cd "$GRID/$arm" && timeout 300 "$SL" -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$w/gold2" </dev/null > "$w/gold2/log" 2>&1)
  g2=$(ls "$w"/gold2/slpp_*/*.uhdm 2>/dev/null | head -1)
  if [ -z "$g2" ]; then echo "$arm NOGOLD2"; continue; fi
  "$CMP" "$w/gold.uhdm" "$g2" > "$w/gold2.cmp" 2>&1
  l=$(wc -l < "$w/gold2.cmp"); h=$(grep -c '^LHS:' "$w/gold2.cmp"; true)
  n=$((n+1)); [ "$l" != 0 ] && nz=$((nz+1))
  echo "$arm $l $h"
done 3< <(cd "$GRID" && find . -name dut.sv | sort)
echo "CALIBRATED=$n NONZERO=$nz"
