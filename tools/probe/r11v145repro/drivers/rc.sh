#!/bin/bash
# rc.sh <case dir> [bin...] : golden (probe flags) cached by case text md5; ours per bin; cmp lines + strict verdict
source /tmp/v11u145_s/env.sh
d=$(cd "$1" && pwd); shift
BINS=${@:-/tmp/v11u145_bin/pristine}
h=$(cat $d/dut.sv | md5sum | cut -c1-12)$(echo $d | md5sum | cut -c1-6)
g=/tmp/v11u145_s/gold/$h
if [ ! -f $g/g.uhdm ]; then rm -rf $g; mkdir -p $g/o
  (cd $d && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $g/o >/dev/null 2>&1 </dev/null); f=$(find $g/o -name '*.uhdm' | head -1); cp "$f" $g/g.uhdm 2>/dev/null; fi
[ -f $g/g.uhdm ] || { echo "$d NOGOLDEN"; exit; }
for b in $BINS; do o=/tmp/v11u145_s/ours/$(echo $d$b | md5sum | cut -c1-12).uhdm; mkdir -p /tmp/v11u145_s/ours; rm -f $o
  (cd $d && $b dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1 </dev/null); rc=$?
  n=$($UHDM_CMP $g/g.uhdm $o 2>&1 | grep -c .)
  s=$($STRICT_CMP --max ${MAX:-2} $g/g.uhdm $o 2>&1 | tr '\n' ' ' | cut -c1-${W:-300})
  echo "${d#/tmp/v11u145_s/} $(basename $b) rc=$rc cmp=$n md5=$(md5sum < $o | cut -c1-8) | $s"
done
