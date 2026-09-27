#!/bin/bash
# grid.sh <casedir> [elab]: golden + pristine + law, uhdm-cmp, strictcmp, order-blind distance, fires
source $(dirname "${BASH_SOURCE[0]}")/env.sh || exit 9
c=$(realpath $1); view=${2:-def}
if echo "$c" | grep -qP "$FENCERE"; then echo "FENCE refuse"; exit 4; fi
rel=$(echo $c | sed -e 's#.*/tools/probe/#tp/#' -e 's#.*/tests/probe/#probe/#' -e 's#.*/v11u187_scr/cases/#v/#')
w=${GROOT:-/tmp/v11u187_g}/$rel.$view; mkdir -p $w
E=""; [ $view = elab ] && E=1
h=$(cat $c/* 2>/dev/null | md5sum | cut -c1-12)
g=$w/golden.$h.uhdm
if [ ! -s $g ]; then
  rm -rf $w/gw; mkdir -p $w/gw
  (cd $c && timeout 300 $SURELOG -parse -nobuiltin -nocache -sv ${E:+-elabuhdm} dut.sv -mt 0 -mp 0 -o $w/gw > $w/sl.log 2>&1)
  f=$(find $w/gw -name '*.uhdm' | head -1); [ -n "$f" ] && cp $f $g
  rm -rf $w/gw
fi
out=""
for t in pris law; do
  b=$PRIS; [ $t = law ] && b=$LAW
  o=$w/$t.uhdm; rm -f $o; rm -rf $w/$t.tr; mkdir -p $w/$t.tr
  (cd $c && env R11U183_TRACE=$w/$t.tr R11U187_TRACE=$w/$t.tr ${GENV:-} timeout 300 $b ${E:+--elabuhdm} dut.sv --single-unit --nobuiltin -o $o > $w/$t.log 2>&1); rc=$?
  if [ ! -s $g ]; then out="$out $t:SURELOG_FAIL"; continue; fi
  if [ ! -s $o ]; then out="$out $t:SLANG_FAIL(rc=$rc)"; continue; fi
  $UHDM_CMP $g $o > $w/$t.cmp 2>&1; cr=$?
  timeout 300 $STRICT --max 0 --dump-a $w/$t.ga.txt --dump-b $w/$t.rec.txt $g $o > $w/$t.strict 2>&1
  sv=$(grep -oE 'STRICT_EQUAL|STRICT_DIFF.*|stage ?1.*' $w/$t.strict | head -1 | tr ' ' '_' | cut -c1-60)
  [ -z "$sv" ] && sv=$(tail -1 $w/$t.strict | tr ' ' '_' | cut -c1-60)
  ob=$(python3 $(dirname "${BASH_SOURCE[0]}")/obdist.py $w/$t.ga.txt $w/$t.rec.txt)
  fires=$(cat $w/$t.tr/* 2>/dev/null | grep -v '^OUT ' | sort | uniq -c | awk '{printf "%s:%s,", $2, $1}')
  md=$(md5sum < $o | cut -c1-8)
  out="$out $t:rc=$rc,cmp=$cr/$(wc -l < $w/$t.cmp),$sv,ob=$ob,md5=$md${fires:+,fires=$fires}"
done
echo "$rel.$view$out"
