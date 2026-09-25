#!/bin/bash
# case.sh <casedir> <binary> <tag> [ENV=VAL ...]
# golden (pinned Surelog, check_probe's SL_ARGS; + -elabuhdm when the case dir holds a file ELAB), built once
# into $GW/<rel>/gold/ and rebuilt when dut.sv is newer; ours into $GW/<rel>/<tag>.uhdm (deleted first);
# uhdm-cmp; uhdm-strictcmp with record dumps; order-blind uhdm-dump distance to golden.
# prints: <rel> <tag> rc=<slang rc> cmp=<lines> strict=<verdict> ob=<order-blind lines vs golden> md5=<8>
. /tmp/r11u153_env.sh
c=$(realpath $1); b=$2; t=$3; shift 3
GW=${GW:-/tmp/r11u153_g}
rel=$(echo $c | sed 's#.*/r11u153verify/cases/##')
w=$GW/$rel; mkdir -p $w
g=$w/gold/golden.uhdm
EL=""; SEL=""; [ -f $c/ELAB ] && { EL="-elabuhdm"; SEL="--elabuhdm"; }
if [ ! -s $g ] || [ $c/dut.sv -nt $g ]; then
  rm -rf $w/gold; mkdir -p $w/gold/w
  (cd $c && $SURELOG -parse -nobuiltin -nocache -sv dut.sv $EL -mt 0 -mp 0 -o $w/gold/w > $w/gold/sl.log 2>&1)
  f=$(find $w/gold/w -name '*.uhdm' | head -1); [ -n "$f" ] && cp $f $g
  rm -rf $w/gold/w
  [ -s $g ] && $UHDM_DUMP $g 2>/dev/null | sed "s#$w/gold/w##g" | sort > $w/gold/ob.txt
fi
o=$w/$t.uhdm; rm -f $o $w/$t.a.txt $w/$t.b.txt
(cd $c && env "$@" $b dut.sv --single-unit --nobuiltin $SEL -o $o > $w/$t.log 2>&1); rc=$?
[ -s $g ] || { echo "$rel $t SURELOG_FAIL rc=$rc"; exit; }
[ -s $o ] || { echo "$rel $t SLANG_FAIL rc=$rc"; exit; }
$UHDM_CMP $g $o > $w/$t.cmp 2>&1
timeout 300 $STRICT_CMP --max 20 --dump-a $w/$t.a.txt --dump-b $w/$t.b.txt $g $o > $w/$t.strict 2>&1
$UHDM_DUMP $o 2>/dev/null | sed "s#$w/##g" | sort > $w/$t.ob.txt
ob=$(diff $w/gold/ob.txt $w/$t.ob.txt | grep -c '^[<>]')
echo "$rel $t rc=$rc cmp=$(wc -l < $w/$t.cmp) strict=$(tail -1 $w/$t.strict | tr ' ' _) ob=$ob md5=$(md5sum < $o | cut -c1-8)"
