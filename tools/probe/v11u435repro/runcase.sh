#!/bin/bash
# usage: runcase.sh <casedir> <binary> <outdir>  -> rc, uhdm-cmp lines, dump distance, md5, strict verdict
SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
SC=/tmp/wt_v11u435/build/uhdm-strictcmp
for v in "$SURELOG" "$UHDM_CMP" "$UHDM_DUMP" "$SC" "$2"; do [ -x "$v" ] || { echo "missing tool $v"; exit 9; }; done
c=$1; b=$2; o=$3; mkdir -p $o
if [ ! -s $o/golden.uhdm ]; then
  rm -rf $o/gw; mkdir -p $o/gw
  (cd $c && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $o/gw >/dev/null 2>&1 </dev/null)
  g=$(find $o/gw -name '*.uhdm' | head -1); [ -n "$g" ] && cp $g $o/golden.uhdm
  [ -s $o/golden.uhdm ] && $UHDM_DUMP $o/golden.uhdm > $o/golden.dump 2>/dev/null
fi
rm -f $o/ours.uhdm $o/ours.dump
(cd $c && $b dut.sv --single-unit --nobuiltin -o $o/ours.uhdm >$o/ours.log 2>&1 </dev/null); rc=$?
[ -s $o/ours.uhdm ] && $UHDM_DUMP $o/ours.uhdm > $o/ours.dump 2>/dev/null
if [ -s $o/golden.uhdm ] && [ -s $o/ours.uhdm ]; then
  n=$($UHDM_CMP $o/golden.uhdm $o/ours.uhdm 2>&1 | wc -l)
  s=$($SC $o/golden.uhdm $o/ours.uhdm 2>&1 | tail -1)
  dd=$(diff <(sed 's#/[^ ]*/##g' $o/golden.dump) <(sed 's#/[^ ]*/##g' $o/ours.dump) | grep -c '^[<>]')
else n=NA; s=NA; dd=NA; fi
md=$(md5sum < $o/ours.uhdm 2>/dev/null | cut -c1-8)
echo "rc=$rc cmp=$n dumpdist=$dd md5=$md strict=$s"
