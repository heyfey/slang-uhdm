#!/bin/bash
# rowdump.sh <sweep workdir> <outdir>: strictcmp --max 400 (+ record dumps) on every STRICT_NOTEQUAL row-mode of
# <workdir>/{surelog,uhdm2rtlil}.csv. Refuses to run without $FENCED; fenced rows are skipped by word boundary.
[ -n "${FENCED:-}" ] || { echo "FENCED unset: refusing"; exit 2; }
W=$1; O=$2; mkdir -p $O
for c in surelog uhdm2rtlil; do
  tail -n +2 $W/$c.csv | awk -F, '$3=="STRICT_NOTEQUAL"{print $1" "$2}' | while read n m; do
    skip=0; for f in $FENCED; do [ "$n" = "$f" ] && skip=1; done; [ $skip = 1 ] && continue
    d=$(ls -d $W/$c/$m/$n-* 2>/dev/null | head -1); [ -n "$d" ] || continue
    gc=$(grep -o 'golden cache hit [^)]*' $d/cmds.txt | awk '{print $4}')
    g=$(find $gc -name '*.uhdm' | head -1); o=$d/slang.uhdm
    t=$O/${c}_${m}_$n
    /tmp/r11u154_bin/strictcmp --max 400 --dump-a $t.a --dump-b $t.b $g $o > $t.out 2>&1
  done
done
