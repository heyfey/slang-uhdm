#!/bin/bash
# ctl117.sh <out> <binA> <binB> <grid-dir>... — CONTROL battery: every dut.sv
# under each landed pass's grid (subdirectories included), compiled by both
# binaries in BOTH forms (testflags: --single-unit --nobuiltin; default:
# --single-unit), rc recorded; prints SAME/DIFF/RC per arm-form and a tally.
# The list is read on fd 3 and every child gets </dev/null.
OUT=${1:?}; A=${2:?}; B=${3:?}; shift 3
mkdir -p "$OUT/a" "$OUT/b"
LIST=$(mktemp "$OUT/list.XXXX")
for g in "$@"; do find "$g" -name dut.sv | sort; done > "$LIST"
n=0; same=0; diff=0; rcd=0
while read -r f <&3; do
  d=$(dirname "$f"); key=$(echo "$f" | sed 's#^/tmp/wt_r11u117/tools/probe/##; s#/#_#g')
  for form in tf def; do
    if [ $form = tf ]; then fl=(--single-unit --nobuiltin); else fl=(--single-unit); fi
    (cd "$d" && timeout 300 "$A" dut.sv "${fl[@]}" -o "$OUT/a/$key.$form.uhdm" </dev/null >/dev/null 2>&1); ra=$?
    (cd "$d" && timeout 300 "$B" dut.sv "${fl[@]}" -o "$OUT/b/$key.$form.uhdm" </dev/null >/dev/null 2>&1); rb=$?
    n=$((n+1))
    if [ $ra -ne $rb ]; then echo "RCDIFF $key.$form $ra $rb"; rcd=$((rcd+1))
    elif [ $ra -ne 0 ]; then echo "RC $key.$form $ra"; same=$((same+1))
    elif cmp -s "$OUT/a/$key.$form.uhdm" "$OUT/b/$key.$form.uhdm"; then same=$((same+1))
    else echo "DIFF $key.$form"; diff=$((diff+1)); fi
  done
done 3< "$LIST"
echo "ARMFORMS=$n SAME=$same DIFF=$diff RCDIFF=$rcd LISTED=$(wc -l < "$LIST")"
