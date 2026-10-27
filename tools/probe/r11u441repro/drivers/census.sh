#!/bin/bash
# usage: census.sh <out.tsv> <pristine> <law> < dirlist ; per case dir: exit codes and md5 on both binaries
out=$1; P=$2; L=$3; [ -x "$P" ] && [ -x "$L" ] || exit 2
: > $out
while read -r c <&3; do
  d=/tmp/r11u441_census/$(echo ${c#/home/heyfey/git-repos/slang-uhdm/tools/probe/} | tr / _); mkdir -p $d; cp $c/*.sv $c/*.svh $d/ 2>/dev/null
  r(){ rm -f $d/o.uhdm; (cd $d && timeout 300 $1 dut.sv --single-unit --nobuiltin -o o.uhdm >/dev/null 2>&1 </dev/null); echo "$? $(md5sum < $d/o.uhdm 2>/dev/null | cut -c1-12)"; }
  a=$(r $P); b=$(r $L)
  echo -e "$c\t$a\t$b\t$([ "$a" = "$b" ] && echo SAME || echo MOVED)" >> $out
done 3< /dev/stdin
