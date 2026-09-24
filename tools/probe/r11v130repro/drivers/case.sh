#!/bin/bash
# case.sh <case dir> -> golden (per content md5), one export per BINS entry (TAG:path), uhdm-cmp lines, strict verdicts
source /tmp/v11u130_env.sh
BINS=${BINS:-"P:/tmp/v11u130_bin/pris.bin L:/tmp/v11u130_bin/law.bin"}
d=$(realpath "$1")
h=$( (cd $d && find . -type f \( -name '*.sv' -o -name '*.svh' -o -name '*.v' -o -name '*.vh' \) | sort | xargs cat) | md5sum | cut -c1-10)
w=/tmp/v11u130_cases/$(echo "$d" | md5sum | cut -c1-8)_$h; mkdir -p $w; echo "$d" > $w/dir
if [ ! -s $w/golden.uhdm ]; then
  rm -rf $w/sl; mkdir -p $w/sl
  (cd $d && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $w/sl >/dev/null 2>&1)
  cp $w/sl/slpp_all/surelog.uhdm $w/golden.uhdm 2>/dev/null
fi
out=""
for tb in $BINS; do
  t=${tb%%:*}; bin=${tb#*:}
  rm -f $w/$t.uhdm
  (cd $d && env $EXTRA $bin dut.sv --single-unit --nobuiltin -o $w/$t.uhdm >/dev/null 2>$w/$t.err); rc=$?
  cmpn=$($UHDM_CMP $w/golden.uhdm $w/$t.uhdm 2>&1 | wc -l)
  st=$($STRICT_CMP --max 20 --dump-a $w/g.rec --dump-b $w/$t.rec $w/golden.uhdm $w/$t.uhdm 2>&1 | tail -1)
  f=$($STRICT_CMP --max 0 $w/golden.uhdm $w/$t.uhdm 2>/dev/null | grep '^fields' | sed 's/fields: //')
  out="$out | $t rc=$rc cmp=$cmpn $st {$f}"
done
rel=$(echo $d | sed 's#.*/tools/probe/##; s#/tmp/##')
echo "$rel$out  [$w]"
