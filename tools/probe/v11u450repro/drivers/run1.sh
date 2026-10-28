#!/bin/bash
# run1.sh <casedir> <binary> <tag> [ENV=VAL ...]; key = full path after tools/probe/ or /tmp/
c=$(cd $1 && pwd); B=$2; t=$3; shift 3
[ -x "$B" ] || { echo "no binary $B"; exit 2; }
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
SC=/tmp/v11u450_bin/strictcmp
for x in "$SL" "$CMP" "$SC" "$DUMP"; do [ -x "$x" ] || { echo "no tool $x"; exit 2; }; done
h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12)
gd=/tmp/v11u450_scr/gold/$h
SRC=dut.sv; [ -f $c/FILES ] && SRC=$(cat $c/FILES)
ST=; GT=; if [ -f $c/TOP ]; then ST="--top-module $(cat $c/TOP)"; GT="--top $(cat $c/TOP)"; fi
if [ ! -f $gd/slpp_all/surelog.uhdm ]; then
  mkdir -p $gd; cp $c/* $gd/
  (cd $gd && timeout 300 $SL -parse -nobuiltin -nocache -sv $ST $SRC > sl.log 2>&1)
  [ -f $gd/slpp_all/surelog.uhdm ] && $DUMP $gd/slpp_all/surelog.uhdm 2>/dev/null | sed 's/ \[[0-9]*\]//g' > $gd/g.dump
fi
key=$(echo $c | sed "s|.*/tools/probe/||; s|^/tmp/||; s|/|_|g")
o=/tmp/v11u450_scr/out/$key/$t; rm -rf $o; mkdir -p $o
(cd $c && env "$@" timeout 300 $B $SRC $GT --single-unit --nobuiltin -o $o/ours.uhdm > $o/ours.log 2>&1; echo $? > $o/rc)
rc=$(cat $o/rc)
if [ ! -f $gd/slpp_all/surelog.uhdm ]; then echo "$key rc=$rc NOGOLDEN md5=$(md5sum < $o/ours.uhdm 2>/dev/null| cut -c1-8)"; exit; fi
if [ ! -s $o/ours.uhdm ]; then echo "$key rc=$rc NOUHDM"; exit; fi
n=$($CMP $gd/slpp_all/surelog.uhdm $o/ours.uhdm 2>&1 | wc -l)
s=$($SC $gd/slpp_all/surelog.uhdm $o/ours.uhdm 2>&1 | tail -1)
$DUMP $o/ours.uhdm 2>/dev/null | sed 's/ \[[0-9]*\]//g' > $o/o.dump
dd=$(diff $gd/g.dump $o/o.dump | grep -c '^[<>]')
echo "$key rc=$rc cmp=$n dist=$dd $s md5=$(md5sum < $o/ours.uhdm | cut -c1-8)"
