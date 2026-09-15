#!/bin/bash
# r11u43 — THE NEUTRAL-BINARY CONTROL: the law binary with R11U43_OFF=1 must
# write the PRISTINE bytes on every arm.  That is what proves the binary
# difference is this law and nothing else.
BIN=${BIN:?}; ROOT=${1:?}
same=0; diff=0
for d in "$ROOT"/*/; do
  a=$(basename "$d"); o="$d/NEU.uhdm"; rm -f "$o"
  ( cd "$d" && R11U43_OFF=1 "$BIN" dut.sv --single-unit -o "$o" >/dev/null 2>&1 )
  p="$d/PRIS.uhdm"
  if [ -f "$o" ] && [ -f "$p" ]; then
    if cmp -s "$o" "$p"; then same=$((same+1)); else diff=$((diff+1)); echo "NEUTRAL-DIFF $a"; fi
  elif [ ! -f "$o" ] && [ ! -f "$p" ]; then same=$((same+1))
  else diff=$((diff+1)); echo "NEUTRAL-DBMISMATCH $a"; fi
done
echo "NEUTRAL same=$same diff=$diff root=$ROOT"
