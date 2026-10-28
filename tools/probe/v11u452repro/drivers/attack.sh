#!/bin/bash
# attack.sh <outfile> <casedir>...: pristine | law | law R11U452_OFF per case
D=/tmp/wt_v11u452/tools/probe/v11u452repro/drivers
P=/tmp/v11u452_bin/pristine; L=/tmp/v11u452_bin/law
[ -x "$P" ] && [ -x "$L" ] || exit 2
out=$1; shift; : > $out
for c in "$@"; do
  [ -d "$c" ] || continue
  a=$($D/run1.sh $c $P pris | cut -d' ' -f2-)
  b=$($D/run1.sh $c $L law | cut -d' ' -f2-)
  o=$($D/run1.sh $c $L lawoff R11U452_OFF=1 | cut -d' ' -f2-)
  ma=${a##*md5=}; mb=${b##*md5=}; mo=${o##*md5=}
  k=$(echo $c | sed 's|.*/cases/||')
  [ "$ma" = "$mb" ] && m=same || m=MOVED
  [ "$ma" = "$mo" ] && off=offOK || off=OFFDIFF
  echo "$k | $a | $b | $m | $off" >> $out
done
