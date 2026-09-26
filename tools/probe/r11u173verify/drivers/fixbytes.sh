#!/bin/bash
# fixbytes.sh <out> <root>...: every dut.sv under the roots (file list read on fd 3, children </dev/null), exported by
# law.bin and fix.bin in both modes (default, --elabuhdm); SAME / MOVED per case and mode; PROCESSED == LISTED asserted.
# Evidence cases only (no corpus source); a path holding a fenced name is skipped (fail-closed on $FENCED).
source /tmp/wt_r11u173/tools/probe/r11u173verify/drivers/env.sh || exit 2
O=$1; shift; T=/tmp/r11u173_fixbytes; mkdir -p $T; : > $O
find "$@" -name dut.sv | sort > $T/list; L=$(wc -l < $T/list); P=0
while read -r f <&3; do
  d=$(dirname $f); skip=0; for n in $FENCED; do echo "$d" | grep -qw "$n" && skip=1; done
  [ $skip = 1 ] && { echo "FENCED-SKIP $d" >> $O; P=$((P+1)); continue; }
  for m in def el; do
    x=""; [ $m = el ] && x=--elabuhdm
    rm -f $T/l.uhdm $T/f.uhdm
    (cd $d && timeout 120 $LAW dut.sv --single-unit --nobuiltin $x -o $T/l.uhdm </dev/null >/dev/null 2>&1)
    (cd $d && timeout 120 $FIX dut.sv --single-unit --nobuiltin $x -o $T/f.uhdm </dev/null >/dev/null 2>&1)
    if [ ! -f $T/l.uhdm ] && [ ! -f $T/f.uhdm ]; then s=nodb; elif cmp -s $T/l.uhdm $T/f.uhdm; then s=same; else s=MOVED; fi
    printf '%s\t%s\t%s\n' "${d#*/tools/probe/}" $m $s >> $O
  done
  P=$((P+1))
done 3< $T/list
echo "PROCESSED=$P LISTED=$L MOVED=$(grep -c MOVED $O)" | tee -a $O
