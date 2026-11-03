#!/bin/bash
# swcheck.sh <casedir>...: md5 of law8 output under each switch vs pristine and law8
B=/tmp/r11u475_bin/law8; P=/tmp/r11u475_bin/pristine
[ -x "$B" ] && [ -x "$P" ] || exit 1
for c in "$@"; do
  W=/tmp/r11u475_swc$c; mkdir -p $W
  m(){ rm -f $W/o.uhdm; (cd $c && env $1 "$2" dut.sv --single-unit --nobuiltin -o $W/o.uhdm >/dev/null 2>&1); echo "$?:$(md5sum < $W/o.uhdm | cut -c1-8)"; }
  pr=$(m X=1 $P); lw=$(m X=1 $B); off=$(m R11U475_OFF=1 $B)
  line="${c#*/cases/} pristine=$pr law=$lw OFF=$off"
  for s in ADDMINT REFRESPELL READCHAIN HEXCASE CAXORKEEP ELABRHSDEF QUALCAFORM; do
    line="$line $s=$(m R11U475_${s}_OFF=1 $B)"
  done
  echo "$line"
done
