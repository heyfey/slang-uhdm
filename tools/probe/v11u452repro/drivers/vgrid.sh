#!/bin/bash
# vgrid.sh <outfile> <casedir>...: verified | verified R11V452_OFF (vs law) | verified R11U452_OFF (vs pristine)
D=/tmp/wt_v11u452/tools/probe/v11u452repro/drivers
V=/tmp/v11u452_bin/verified; [ -x "$V" ] || exit 2
out=$1; shift; : > $out
for c in "$@"; do
  [ -d "$c" ] || continue
  k=$(echo $c | sed 's|.*/tools/probe/||; s|/|_|g')
  v=$($D/run1.sh $c $V ver | cut -d' ' -f2-)
  w=$($D/run1.sh $c $V veroffv R11V452_OFF=1 | cut -d' ' -f2-)
  u=$($D/run1.sh $c $V veroffu R11U452_OFF=1 | cut -d' ' -f2-)
  O=/tmp/v11u452_scr/out/$k
  cmp -s $O/veroffv/ours.uhdm $O/law/ours.uhdm && a=VoffEQlaw || a=VoffNElaw
  cmp -s $O/veroffu/ours.uhdm $O/pris/ours.uhdm && b=UoffEQpris || b=UoffNEpris
  cmp -s $O/ver/ours.uhdm $O/law/ours.uhdm && m=ver=law || m=VERMOVED
  echo "$(echo $c | sed 's|.*/cases/||') | $v | $m | $a | $b" >> $out
done
