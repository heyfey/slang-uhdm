#!/bin/bash
# bytes.sh <out.txt> <dir>...: every dut.sv case under the dirs, run with the landed binary (pris.bin) and the
# refined binary (fix.bin) and fix.bin under R11U153_OFF=1; prints MOVER lines and a count per dir. Bytes only
# (no golden). Case dirs only (tools/probe grids): never a corpus source.
OUT=$1; shift; S=/tmp/r11u153_bytes; : > $OUT
for d in "$@"; do
  n=0; m=0; bad=0
  while IFS= read -r c <&3; do
    n=$((n+1)); k=$(echo $c | md5sum | cut -c1-12); mkdir -p $S/$k
    for t in L F M; do rm -f $S/$k/$t.uhdm; done
    (cd $c && /tmp/r11u153_bin/pris.bin dut.sv --single-unit --nobuiltin -o $S/$k/L.uhdm > /dev/null 2>&1 < /dev/null)
    (cd $c && /tmp/r11u153_bin/fix.bin dut.sv --single-unit --nobuiltin -o $S/$k/F.uhdm > /dev/null 2>&1 < /dev/null)
    (cd $c && R11U153_OFF=1 /tmp/r11u153_bin/fix.bin dut.sv --single-unit --nobuiltin -o $S/$k/M.uhdm > /dev/null 2>&1 < /dev/null)
    cmp -s $S/$k/L.uhdm $S/$k/F.uhdm || { m=$((m+1)); echo "MOVER ${c#/tmp/wt_r11u153/tools/probe/}" >> $OUT; }
    cmp -s $S/$k/L.uhdm $S/$k/M.uhdm || { bad=$((bad+1)); echo "MASTER_OFF_DIFFERS ${c#/tmp/wt_r11u153/tools/probe/}" >> $OUT; }
  done 3< <(find $d -name dut.sv -printf '%h\n' | sort)
  echo "$d: cases=$n movers=$m master_off_differs=$bad" >> $OUT
done
