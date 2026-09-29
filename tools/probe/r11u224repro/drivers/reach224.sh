#!/bin/bash
# reach224.sh <pass number> <case dir root>... : § landingSwitchReach224's reach table. Every dut.sv under the given
# roots (a pass's own cases), both views, run with the law binary ($B/$LAWBIN) alone, under R11U<N>_OFF (the old
# whole-pass switch) and under R11U224_SPLIT<N>A_OFF (its ground-A half). Prints one line per case-view:
# <case> old=moved|same split=moved|same, then the counts. Fence fail-closed through env.sh / case.sh.
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
N=$1; shift; LAWBIN=${LAWBIN:-law.bin}
export HERE N LAWBIN
one() { c=$1; el=$2
  m0=$(EL=$el bash $HERE/case.sh $c R0 $B/$LAWBIN 2>/dev/null | grep -o 'md5=[0-9a-f]*')
  m1=$(EL=$el bash $HERE/case.sh $c R1 $B/$LAWBIN R11U${N}_OFF=1 2>/dev/null | grep -o 'md5=[0-9a-f]*')
  m2=$(EL=$el bash $HERE/case.sh $c R2 $B/$LAWBIN R11U224_SPLIT${N}A_OFF=1 2>/dev/null | grep -o 'md5=[0-9a-f]*')
  echo "$c$([ $el = 1 ] && echo _el) old=$([ "$m0" = "$m1" ] && echo same || echo moved) split=$([ "$m0" = "$m2" ] && echo same || echo moved) oldEqSplit=$([ "$m1" = "$m2" ] && echo yes || echo no)"; }
export -f one
for r in "$@"; do find $r -name dut.sv -printf '%h\n'; done | sort -u | while read c; do echo "$c 0"; echo "$c 1"; done | xargs -P3 -L1 bash -c 'one $0 $1' | sort > $S/reach$N.txt
echo "pass $N: $(wc -l < $S/reach$N.txt) case-views; old moves $(grep -c 'old=moved' $S/reach$N.txt); split moves $(grep -c 'split=moved' $S/reach$N.txt); split moves where old does not $(grep 'split=moved' $S/reach$N.txt | grep -c 'old=same'); split==old bytes $(grep -c 'oldEqSplit=yes' $S/reach$N.txt)"
