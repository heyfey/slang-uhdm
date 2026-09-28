#!/bin/bash
# grid <casedir> <binary> <tag> [ENV=VAL...]; ELAB=1 elaborated view.
# Prints: rel tag cmp cmplines strict rc dumpmd5 fires
source $(dirname "${BASH_SOURCE[0]}")/env.sh || exit 9
c=$(realpath $1); b=$2; t=$3; shift 3
if echo "$c" | grep -qP "$FENCED_RE"; then echo "FENCE refuse $c"; exit 4; fi
GW=${GW:-/tmp/v11u192_g}
rel=$(echo $c | sed -e "s#.*/tools/probe/#tp/#" -e "s#.*/tests/probe/#probe/#" -e "s#^/tmp/#tmp/#"); [ -n "${ELAB:-}" ] && rel=$rel.elab
w=$GW/$rel; mkdir -p $w
g=$w/gold/golden.uhdm
if [ ! -s $g ] || [ $c/dut.sv -nt $g ]; then
  rm -rf $w/gold; mkdir -p $w/gold/w
  (cd $c && $SURELOG -parse -nobuiltin -nocache -sv ${ELAB:+-elabuhdm} dut.sv -mt 0 -mp 0 -o $w/gold/w > $w/gold/sl.log 2>&1)
  f=$(find $w/gold/w -name '*.uhdm' | head -1); [ -n "$f" ] && cp $f $g
  rm -rf $w/gold/w
fi
o=$w/$t.uhdm; rm -f $o; rm -rf $w/$t.tr; mkdir -p $w/$t.tr
(cd $c && env R11U192_TRACE=$w/$t.tr "$@" $b ${ELAB:+--elabuhdm} dut.sv --single-unit --nobuiltin -o $o > $w/$t.log 2>&1); rc=$?
fires=$( (cat $w/$t.tr/* 2>/dev/null | grep -v "^OUT ") | sort | uniq -c | awk '{printf "%s:%s,", $2, $1}')
[ -s $g ] || { echo "$rel $t SURELOG_FAIL rc=$rc"; exit; }
[ -s $o ] || { echo "$rel $t SLANG_FAIL rc=$rc"; exit; }
$UHDM_CMP $g $o > $w/$t.cmp 2>&1; cr=$?
$STRICT_CMP --max ${MAX:-200} --dump-a $w/$t.a.txt --dump-b $w/$t.b.txt $g $o > $w/$t.strict 2>&1
$UHDM_DUMP $o 2>/dev/null | sed -e "s#$w/$t.uhdm#W/X.uhdm#" -e "s#$w#W#g" -e "s#$c#C#g" > $w/$t.dump
$UHDM_DUMP $g 2>/dev/null | sed -e "s#$w/gold/w/##g" -e "s#$w#W#g" -e "s#$c#C#g" > $w/gold.dump
echo "$rel $t cmp=$cr cmplines=$(wc -l < $w/$t.cmp) strict=$(tail -1 $w/$t.strict | tr ' ' _) rc=$rc md5=$(md5sum < $w/$t.dump | cut -c1-8) fires=${fires:-none}"
