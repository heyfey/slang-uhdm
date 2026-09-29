#!/bin/bash
# r11u227 (from r11u224repro/drivers/reach224.sh): reach227.sh <old switch> <split switch> <tag> <case dir root>... :
# § landingSwitchReach227's reach table. Every dut.sv under the given roots (the landing's own cases), both views, run
# with the law binary ($B/$LAWBIN) alone, under the old whole-pass switch and under the new ground-A split switch.
# Prints one line per case-view: <case> old=moved|same split=moved|same oldEqSplit=yes|no, then the counts.
# Fence fail-closed through env.sh / case.sh.
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
OLD=$1; SPL=$2; TAG=$3; shift 3; LAWBIN=${LAWBIN:-law.bin}
export HERE OLD SPL LAWBIN
one() { c=$1; el=$2
  m0=$(EL=$el bash $HERE/case.sh $c R0 $B/$LAWBIN 2>/dev/null | grep -o 'md5=[0-9a-f]*')
  m1=$(EL=$el bash $HERE/case.sh $c R1 $B/$LAWBIN $OLD=1 2>/dev/null | grep -o 'md5=[0-9a-f]*')
  m2=$(EL=$el bash $HERE/case.sh $c R2 $B/$LAWBIN $SPL=1 2>/dev/null | grep -o 'md5=[0-9a-f]*')
  echo "$c$([ $el = 1 ] && echo _el) old=$([ "$m0" = "$m1" ] && echo same || echo moved) split=$([ "$m0" = "$m2" ] && echo same || echo moved) oldEqSplit=$([ "$m1" = "$m2" ] && echo yes || echo no)"; }
export -f one
for r in "$@"; do find $r -name dut.sv -printf '%h\n'; done | sort -u | while read c; do echo "$c 0"; echo "$c 1"; done | xargs -P3 -L1 bash -c 'one $0 $1' | sort > $S/reach_$TAG.txt
echo "$TAG ($OLD vs $SPL): $(wc -l < $S/reach_$TAG.txt) case-views; old moves $(grep -c 'old=moved' $S/reach_$TAG.txt); split moves $(grep -c 'split=moved' $S/reach_$TAG.txt); split moves where old does not $(grep 'split=moved' $S/reach_$TAG.txt | grep -c 'old=same'); split==old bytes $(grep -c 'oldEqSplit=yes' $S/reach_$TAG.txt)"
