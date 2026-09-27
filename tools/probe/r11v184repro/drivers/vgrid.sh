#!/bin/bash
# vgrid.sh <casedir> <binary> <tag> [ENV=VAL...]  (ELAB=1: the elaborated view)
# golden from the pinned Surelog (cached per case under /tmp/v11u184_g), ours from <binary>;
# prints: rel tag rc cmplines strict md5(dump)
source $(dirname "${BASH_SOURCE[0]}")/env.sh || exit 9
c=$(realpath $1); b=$2; t=$3; shift 3
if echo "$c" | grep -qP "$FENCED_RE"; then echo "FENCE refuse $c"; exit 4; fi
rel=$(echo $c | sed -e "s#.*/tools/probe/#tp/#" -e "s#.*/tests/probe/#probe/#"); [ -n "${ELAB:-}" ] && rel=$rel.elab
w=/tmp/v11u184_g/$rel; mkdir -p $w
g=$w/gold/golden.uhdm
stamp=$(cat $c/*.sv $c/*.svh 2>/dev/null | md5sum | cut -c1-12)
if [ ! -s $g ] || [ "$(cat $w/gold/stamp 2>/dev/null)" != "$stamp" ]; then
  rm -rf $w/gold; mkdir -p $w/gold/w
  (cd $c && $SURELOG -parse -nobuiltin -nocache -sv ${ELAB:+-elabuhdm} dut.sv -mt 0 -mp 0 -o $w/gold/w > $w/gold/sl.log 2>&1)
  f=$(find $w/gold/w -name '*.uhdm' | head -1); [ -n "$f" ] && cp $f $g
  rm -rf $w/gold/w; echo $stamp > $w/gold/stamp
  [ -s $g ] && $UHDM_DUMP $g 2>/dev/null > $w/gold/golden.dump
fi
o=$w/$t.uhdm; rm -f $o
(cd $c && env "$@" $b ${ELAB:+--elabuhdm} dut.sv --single-unit --nobuiltin -o $o > $w/$t.log 2>&1); rc=$?
[ -s $g ] || { echo "$rel $t SURELOG_FAIL rc=$rc"; exit; }
[ -s $o ] || { echo "$rel $t SLANG_FAIL rc=$rc"; exit; }
$UHDM_CMP $g $o > $w/$t.cmp 2>&1
$STRICT_CMP --max ${MAX:-100000} --dump-a $w/$t.a.txt --dump-b $w/$t.b.txt $g $o > $w/$t.strict 2>&1
$UHDM_DUMP $o 2>/dev/null | sed -e "s#$w/$t.uhdm#W/X.uhdm#" -e "s#$w#W#g" > $w/$t.dump
echo "$rel $t rc=$rc cmplines=$(wc -l < $w/$t.cmp) strict=$(tail -1 $w/$t.strict | tr ' ' _) md5=$(md5sum < $w/$t.dump | cut -c1-8)"
