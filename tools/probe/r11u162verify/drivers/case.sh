#!/bin/bash
# case.sh <casedir> <tag> <binary> [ENV=VAL ...]
# One case: golden with check_probe's Surelog arguments (EL=1: + -elabuhdm, ours + --elabuhdm), cached per
# case text under $GW; ours with --single-unit --nobuiltin under the given environment; uhdm-cmp; uhdm-strictcmp
# (records dumped).  Prints one line: rel tag cmp=<rc> cmplines=<n> strict=<last line> rc=<rc> md5=<8>.
[ -n "$FENCED" ] || { echo "case.sh: export FENCED (drivers/env.sh)" >&2; exit 2; }
c=$(realpath $1); t=$2; b=$3; shift 3
for n in $FENCED; do echo "$c" | grep -qw "$n" && { echo "case.sh: fenced path refused" >&2; exit 2; }; done
GW=${GW:-/tmp/r11u162_g}
rel=$(echo $c | sed "s#.*/r11u162verify/cases/##")
ek=""; sx=""; ox=""; [ "${EL:-0}" = 1 ] && { ek="_el"; sx="-elabuhdm"; ox="--elabuhdm"; }
w=$GW/$rel$ek; mkdir -p $w
h=$(cat $c/dut.sv $c/*.svh 2>/dev/null | md5sum | cut -c1-12)
g=$w/gold_$h/golden.uhdm
if [ ! -s $g ] && [ ! -e $w/gold_$h/failed ]; then
  rm -rf $w/gold_*; mkdir -p $w/gold_$h/w
  (cd $c && timeout 300 $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 $sx -o $w/gold_$h/w > $w/gold_$h/sl.log 2>&1)
  f=$(find $w/gold_$h/w -name '*.uhdm' | head -1); [ -n "$f" ] && cp $f $g || touch $w/gold_$h/failed
  rm -rf $w/gold_$h/w
fi
o=$w/$t.uhdm; rm -f $o
(cd $c && env "$@" timeout 300 $b dut.sv --single-unit --nobuiltin $ox -o $o > $w/$t.log 2>&1); rc=$?
[ -s $g ] || { echo "$rel$ek $t SURELOG_FAIL rc=$rc"; exit 0; }
[ -s $o ] || { echo "$rel$ek $t SLANG_FAIL rc=$rc"; exit 0; }
$UHDM_CMP $g $o > $w/$t.cmp 2>&1; cr=$?
$STRICT_CMP --max 100000 $g $o > $w/$t.strict 2>&1
echo "$rel$ek $t cmp=$cr cmplines=$(wc -l < $w/$t.cmp) strict=$(tail -1 $w/$t.strict | tr ' ' _) rc=$rc md5=$(md5sum < $o | cut -c1-8)"
