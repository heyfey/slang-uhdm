#!/bin/bash
# usage: switches.sh <out.tsv> <casedir>...: pristine, law3, law3 with R11U443_OFF, and law3 with each law switch: rc + md5
P=/tmp/r11u443_bin/pristine; L=/tmp/r11u443_bin/law3; W=/tmp/r11u443_sw
[ -x $P ] && [ -x $L ] || exit 2
out=$1; shift; : > $out
for c in "$@"; do
  key="$(basename $(dirname $c))/$(basename $c)"; d=$W/$(echo $key | tr / _); mkdir -p $d; cp $c/dut.sv $d/
  run() { rm -f $d/o.uhdm; (cd $d && timeout 120 env $2 $1 dut.sv --single-unit --nobuiltin -o o.uhdm >/dev/null 2>&1 </dev/null); echo "$?:$(md5sum < $d/o.uhdm 2>/dev/null | cut -c1-8)"; }
  p=$(run $P X=1); l=$(run $L X=1); off=$(run $L R11U443_OFF=1)
  line="$key	p=$p	l=$l	OFF=$off"
  for s in PROGFEVAR PROGLVBIND IFACELVBIND FEPACKEDTS; do line="$line	$s=$(run $L R11U443_${s}_OFF=1)"; done
  echo "$line" >> $out
done
