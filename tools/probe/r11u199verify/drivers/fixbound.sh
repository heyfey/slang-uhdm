#!/bin/bash
# fixbound.sh <out> <dir>...: the fix's case boundary.  For every case dir (a dut.sv) under the given tools/probe dirs,
# both views (default; --elabuhdm): md5 of law.bin (HEAD), fix.bin, fix.bin with R11V199_OFF=1 (must equal law.bin),
# and each refinement switch alone on fix.bin.  Prints one line per case-mode: SAME / MOVED (fix vs law) and the
# switch that restores law's bytes.  Refuses fenced paths (fail-closed on $FENCED).
source "$(dirname "$0")/env.sh" || exit 2
O=$1; shift; : > $O; T=/tmp/r11u199_fb; mkdir -p $T
for d in "$@"; do
  for c in $(find $R199_ROOT/tools/probe/$d -name dut.sv -printf '%h\n' | sort); do
    echo "$c" | grep -Pq "$FENCE_RE" && { echo "FENCED-SKIP" >> $O; continue; }
    for el in "" "--elabuhdm"; do
      h(){ rm -f $T/o.uhdm; (cd $c && env "$@" dut.sv --single-unit --nobuiltin $el -o $T/o.uhdm > /dev/null 2>&1); md5sum < $T/o.uhdm 2>/dev/null | cut -c1-10; }
      a=$(h $LAW); b=$(h $FIX); z=$(h R11V199_OFF=1 $FIX)
      s1=$(h R11V199_UCOWNER_OFF=1 $FIX); s2=$(h R11V199_UCVARSEL_OFF=1 $FIX); s3=$(h R11V199_GFCALLROOT_OFF=1 $FIX)
      v=SAME; [ "$a" != "$b" ] && v=MOVED
      echo "${c#$R199_ROOT/tools/probe/}${el:+ el} $v off_all=$([ "$z" = "$a" ] && echo law || echo DIFF) UCOWNER_OFF=$([ "$s1" = "$b" ] && echo fix || ([ "$s1" = "$a" ] && echo law || echo other)) UCVARSEL_OFF=$([ "$s2" = "$b" ] && echo fix || ([ "$s2" = "$a" ] && echo law || echo other)) GFCALLROOT_OFF=$([ "$s3" = "$b" ] && echo fix || ([ "$s3" = "$a" ] && echo law || echo other))" >> $O
    done
  done
done
echo FIXBOUND_DONE >> $O
