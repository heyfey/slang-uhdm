#!/bin/bash
# fixswitch.sh: the fix binary's switches on every case (default mode): both refinement switches set must give
# law.bin's bytes (the grid's on.uhdm), each alone must give law.bin's bytes on the cases of its refinement,
# and the three landing switches must give the pre-landing bytes (the grid's alloff.uhdm).  Case-only.
source $(dirname $0)/env.sh
C=$(cd $(dirname $0)/../cases && pwd); T=$(mktemp -d /tmp/r11u162_fxs.XXXX); F=/tmp/r11u162_bin/fix.bin
n=0; both=0; all=0; sel=""; mac=""
for d in $(cd $C && ls -d */*); do
  w=/tmp/r11u162_g/$d; [ -f $w/on.uhdm ] || continue; n=$((n+1))
  run(){ rm -f $T/o.uhdm; (cd $C/$d && env "$@" $F dut.sv --single-unit --nobuiltin -o $T/o.uhdm >/dev/null 2>&1); }
  run R11V162_IFSIGSEL_OFF=1 R11V162_IFSIGMACRO_OFF=1; cmp -s $T/o.uhdm $w/on.uhdm && both=$((both+1)) || echo "BOTH-OFF DIFF $d"
  run R11U154_OFF=1 R11V154_VIDMOD_OFF=1 R11U155_OFF=1; cmp -s $T/o.uhdm $w/alloff.uhdm && all=$((all+1)) || echo "ALLOFF DIFF $d"
  if [ -f $w/fix.uhdm ] && ! cmp -s $w/fix.uhdm $w/on.uhdm; then
    run R11V162_IFSIGSEL_OFF=1; cmp -s $T/o.uhdm $w/on.uhdm && sel="$sel $d"
    run R11V162_IFSIGMACRO_OFF=1; cmp -s $T/o.uhdm $w/on.uhdm && mac="$mac $d"
  fi
done; rm -rf $T
echo "cases=$n both-switches=law-bytes:$both landing-switches=pre-landing-bytes:$all"
echo "IFSIGSEL_OFF alone restores law bytes on:$sel"
echo "IFSIGMACRO_OFF alone restores law bytes on:$mac"
