#!/bin/bash
# allrec.sh <sweepdir> <outdir>: every differing strict record (strictcmp_raw --max 100000) of every
# STRICT_NOTEQUAL row-mode of a sweep's surelog.csv and uhdm2rtlil.csv, one file per row-mode.
# FAIL-CLOSED on $FENCED: refuses to run without the four names and skips a fenced row by name.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "allrec.sh: export FENCED (four names) first" >&2; exit 1; }
W=$1; O=$2; mkdir -p $O
SC=${SC:-/tmp/r11u167_bin/strictcmp_raw}
for C in surelog uhdm2rtlil; do
  awk -F, '$3=="STRICT_NOTEQUAL"{print $1" "$2}' $W/$C.csv | while read T M; do
    skip=0; for f in $FENCED; do [ "$T" = "$f" ] && skip=1; done; [ $skip = 1 ] && continue
    d=$(ls -d $W/$C/$M/$T-* 2>/dev/null | head -1); [ -n "$d" ] || continue
    g=$(grep -o 'golden cache hit [^)]*' $d/cmds.txt | awk '{print $4}')/golden.uhdm
    [ -s $d/slang.uhdm ] && [ -s $g ] || continue
    timeout 600 $SC --max 100000 $g $d/slang.uhdm > $O/${C}__${M}__$T.txt 2>&1
  done
done
echo done
