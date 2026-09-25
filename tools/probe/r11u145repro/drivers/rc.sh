#!/bin/bash
# rc.sh <case dir with dut.sv> [bin...]: golden (probe flags) once per dir (cached in dir/.g), ours per bin; strict verdict
source /tmp/r11u145_env.sh
d=$(cd "$1" && pwd); shift
BINS=${@:-/tmp/r11u145_bin/pristine}
g=/tmp/r11u145_s/gold/$(echo $d | md5sum | cut -c1-12)
if [ ! -f $g/g.uhdm ] || [ $d/dut.sv -nt $g/g.uhdm ]; then rm -rf $g; mkdir -p $g/o
  (cd $d && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $g/o >/dev/null 2>&1); f=$(find $g/o -name '*.uhdm' | head -1); cp "$f" $g/g.uhdm 2>/dev/null; fi
for b in $BINS; do o=/tmp/r11u145_s/ours/$(echo $d$b | md5sum | cut -c1-12).uhdm; mkdir -p /tmp/r11u145_s/ours; rm -f $o
  (cd $d && $b dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1); rc=$?
  n=$($UHDM_CMP $g/g.uhdm $o 2>&1 | grep -c .)
  s=$($STRICT_CMP --max ${MAX:-3} $g/g.uhdm $o 2>&1 | tail -${TAILN:-1})
  echo "$(basename $d) $(basename $b) rc=$rc cmp=$n | $s"
done
