#!/bin/bash
# run1.sh <casedir> <binary> <tag> [ENV=VAL ...]
c=$(cd $1 && pwd); B=$2; t=$3; shift 3
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
SC=/tmp/v11u433_bin/uhdm-strictcmp
for v in "$SL" "$CMP" "$SC" "$B"; do [ -x "$v" ] || { echo "missing tool $v"; exit 2; }; done
h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12)
gd=/tmp/v11u433_scr/gold/$h
SRC=dut.sv; [ -f $c/FILES ] && SRC=$(cat $c/FILES)
ST=; GT=; if [ -f $c/TOP ]; then ST="--top-module $(cat $c/TOP)"; GT="--top $(cat $c/TOP)"; fi
if [ ! -f $gd/slpp_all/surelog.uhdm ]; then
  rm -rf $gd; mkdir -p $gd; cp $c/* $gd/
  (cd $gd && timeout 300 $SL -parse -nobuiltin -nocache -sv $ST $SRC > sl.log 2>&1)
fi
key=$(echo $c | sed "s|.*/cases/||; s|/|_|g")
o=/tmp/v11u433_scr/out/$key/$t; rm -rf $o; mkdir -p $o
(cd $c && env "$@" timeout 300 $B $SRC $GT --single-unit --nobuiltin -o $o/ours.uhdm > $o/ours.log 2>&1; echo $? > $o/rc)
echo $gd > $o/gold
rc=$(cat $o/rc)
if [ ! -f $gd/slpp_all/surelog.uhdm ]; then echo "$key rc=$rc NOGOLDEN"; exit; fi
if [ ! -s $o/ours.uhdm ]; then echo "$key rc=$rc NOUHDM"; exit; fi
n=$($CMP $gd/slpp_all/surelog.uhdm $o/ours.uhdm 2>&1 | wc -l)
s=$($SC $gd/slpp_all/surelog.uhdm $o/ours.uhdm 2>&1 | tail -1)
echo "$key rc=$rc cmp=$n $s"
