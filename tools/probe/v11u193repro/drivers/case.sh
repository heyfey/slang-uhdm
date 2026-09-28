#!/bin/bash
# usage: case.sh <case dir>  -> judges with pris.bin and law.bin (and $EXTRA_BIN named X if set)
set -u
. "$(dirname "$0")/env.sh" || exit 3
D=$(cd "$1" && pwd); v193_fenced "$D" && { echo "fenced path refused" >&2; exit 3; }
TOP=${TOP:-dut.sv}
K=$( (echo "$D"; cat "$D"/*.sv "$D"/*.svh "$D"/*.v 2>/dev/null) | md5sum | cut -c1-16); G=$V193_GOLD/$K
if [ ! -s "$G/golden.uhdm" ]; then mkdir -p "$G/w"; ( cd "$D" && "$SURELOG" -parse -nobuiltin -nocache -sv $TOP -mt 0 -mp 0 -o "$G/w" > "$G/sl.log" 2>&1 )
  u=$(find "$G/w" -name '*.uhdm' | head -1); [ -n "$u" ] && cp "$u" "$G/golden.uhdm"; rm -rf "$G/w"; fi
[ -s "$G/golden.uhdm" ] || { echo "$1 SURELOG_FAIL"; exit 1; }
line="$(basename $D)"
for b in ${BINS:-pris law}; do
  O=$V193_RUN/$(echo "$D" | md5sum | cut -c1-12)/$b; mkdir -p $O; rm -f $O/*
  ( cd "$D" && env ${ENVX:-} $V193_BIN/$b.bin $TOP --single-unit --nobuiltin -o "$O/ours.uhdm" > "$O/slang.log" 2>&1; echo "rc=$?" >> "$O/slang.log" )
  rc=$(tail -1 $O/slang.log)
  if [ ! -s $O/ours.uhdm ]; then line="$line | $b $rc NOOUT"; continue; fi
  "$UHDM_CMP" "$G/golden.uhdm" "$O/ours.uhdm" > "$O/cmp.txt" 2>&1
  "$SCMP" --max 20 --dump-a "$O/a.rec" --dump-b "$O/b.rec" "$G/golden.uhdm" "$O/ours.uhdm" > "$O/strict.txt" 2>&1
  st=$(tail -1 $O/strict.txt | tr '\t' ' ' | cut -c1-40); od=$(grep -m1 -o 'objects_differing=[0-9]*' $O/strict.txt)
  first=$(grep -m1 -E '^#[0-9]+' $O/strict.txt | tr ' ' '_')
  line="$line | $b $rc cmp=$(wc -l < $O/cmp.txt) $st $od $first md5=$(md5sum < $O/ours.uhdm | cut -c1-8)"
done
cp $G/golden.uhdm $V193_RUN/$(echo "$D" | md5sum | cut -c1-12)/golden.uhdm
echo "$line"
