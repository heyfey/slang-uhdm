#!/bin/bash
# awaybytes.sh <dirlist> <out> : pristine and law on each case dir (dut.sv, --single-unit
# --nobuiltin), outputs under /tmp/v11u475_away/<dir>; prints dir, both exit codes and SAME/DIFF
P=/tmp/v11u475_bin/pristine; L=/tmp/v11u475_bin/law
[ -x "$P" ] && [ -x "$L" ] || exit 1
while read d; do
  W=/tmp/v11u475_away$d; mkdir -p $W; rm -f $W/p.uhdm $W/l.uhdm
  (cd $d && timeout 120 $P dut.sv --single-unit --nobuiltin -o $W/p.uhdm >/dev/null 2>&1 </dev/null); rp=$?
  (cd $d && timeout 120 $L dut.sv --single-unit --nobuiltin -o $W/l.uhdm >/dev/null 2>&1 </dev/null); rl=$?
  s=DIFF; cmp -s $W/p.uhdm $W/l.uhdm && s=SAME
  echo "$d $rp $rl $s"
done < $1 > $2
