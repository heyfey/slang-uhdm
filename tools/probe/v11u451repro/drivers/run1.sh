#!/bin/bash
# run1.sh <casedir> <binary> <tag> [ENV=VAL ...]
c=$(cd $1 && pwd); B=$2; t=$3; shift 3
[ -x "$B" ] || { echo "no binary $B"; exit 2; }
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
SC=/tmp/wt_v11u451/build/uhdm-strictcmp
for x in "$SL" "$CMP" "$SC" "$DUMP"; do [ -x "$x" ] || { echo "no tool $x"; exit 2; }; done
h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12)
gd=/tmp/v11u451_gold/$h
SRC=dut.sv; [ -f $c/FILES ] && SRC=$(cat $c/FILES)
ST=; GT=; if [ -f $c/TOP ]; then ST="--top-module $(cat $c/TOP)"; GT="--top $(cat $c/TOP)"; fi
if [ ! -f $gd/done ]; then
  rm -rf $gd; mkdir -p $gd; cp $c/* $gd/
  (cd $gd && timeout 300 $SL -parse -nobuiltin -nocache -sv $ST $SRC > sl.log 2>&1; echo $? > slrc)
  [ -f $gd/slpp_all/surelog.uhdm ] && $DUMP $gd/slpp_all/surelog.uhdm > $gd/gold.dump 2>&1
  touch $gd/done
fi
key=$(echo $c | sed "s|.*cases/||; s|/|_|g")
o=/tmp/v11u451_out/$key/$t; rm -rf $o; mkdir -p $o
(cd $c && env "$@" timeout 300 $B $SRC $GT --single-unit --nobuiltin -o $o/ours.uhdm > $o/ours.log 2>&1; echo $? > $o/rc)
rc=$(cat $o/rc)
if [ ! -f $gd/slpp_all/surelog.uhdm ]; then echo "$key rc=$rc NOGOLDEN slrc=$(cat $gd/slrc) md5=$(md5sum < $o/ours.uhdm 2>/dev/null| cut -c1-8)"; exit; fi
if [ ! -s $o/ours.uhdm ]; then echo "$key rc=$rc NOUHDM $(grep -m1 -i error $o/ours.log)"; exit; fi
$DUMP $o/ours.uhdm > $o/ours.dump 2>&1
n=$($CMP $gd/slpp_all/surelog.uhdm $o/ours.uhdm 2>&1 | wc -l)
s=$($SC $gd/slpp_all/surelog.uhdm $o/ours.uhdm 2>&1 | tail -1)
d=$(diff <(sed 's/\[[0-9]*\]//g' $gd/gold.dump | grep -v '^\(Elapsed\|UHDM\)' ) <(sed 's/\[[0-9]*\]//g' $o/ours.dump| grep -v '^\(Elapsed\|UHDM\)') | grep -c '^[<>]')
echo "$key rc=$rc cmp=$n dd=$d $s md5=$(md5sum < $o/ours.uhdm | cut -c1-8)"
