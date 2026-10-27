#!/bin/bash
# run1.sh <casedir> <slang-uhdm binary> <outtag> [ENV=VAL ...]: golden (cached per
# case text) + ours + uhdm-cmp line count + uhdm-strictcmp verdict + record distance
# (golden vs ours on the canon walk with each typespec's vpiInstance column);
# outputs keyed on the FULL repro path under /tmp/v11u446_scr/out.
c=$(cd $1 && pwd); B=$2; t=$3; shift 3
[ -x "$B" ] || { echo "no binary $B"; exit 2; }
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
SC=${STRICTCMP:-/tmp/v11u446_tools/uhdm-strictcmp}; RC=${RECCMP:-/tmp/v11u446_tools/sc2}
for x in $SL $CMP $SC $RC; do [ -x "$x" ] || { echo "no tool $x"; exit 2; }; done
h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12)
gd=/tmp/v11u446_scr/gold/$h
SRC=dut.sv; [ -f $c/FILES ] && SRC=$(cat $c/FILES)
ST=; GT=; if [ -f $c/TOP ]; then ST="--top-module $(cat $c/TOP)"; GT="--top $(cat $c/TOP)"; fi
if [ ! -f $gd/slpp_all/surelog.uhdm ]; then
  mkdir -p $gd; cp $c/* $gd/
  (cd $gd && timeout 300 $SL -parse -nobuiltin -nocache -sv $ST $SRC > sl.log 2>&1)
fi
key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
o=/tmp/v11u446_scr/out/$key/$t; rm -rf $o; mkdir -p $o
(cd $c && env "$@" timeout 300 $B $SRC $GT --single-unit --nobuiltin -o $o/ours.uhdm > $o/ours.log 2>&1; echo $? > $o/rc)
rc=$(cat $o/rc)
if [ ! -f $gd/slpp_all/surelog.uhdm ]; then echo "$key $t rc=$rc NOGOLDEN md5=$(md5sum < $o/ours.uhdm 2>/dev/null| cut -c1-8)"; exit; fi
if [ ! -s $o/ours.uhdm ]; then echo "$key $t rc=$rc NOUHDM"; exit; fi
n=$($CMP $gd/slpp_all/surelog.uhdm $o/ours.uhdm 2>&1 | wc -l)
s=$($SC $gd/slpp_all/surelog.uhdm $o/ours.uhdm 2>&1 | tail -1)
FORCE2=1 $RC --dump-a $o/g.rec --dump-b $o/o.rec $gd/slpp_all/surelog.uhdm $o/ours.uhdm > /dev/null 2>&1
sed -i 's/#[TD]$//' $o/g.rec $o/o.rec
all=$(diff $o/g.rec $o/o.rec | grep -c '^[<>]')
echo "$key $t rc=$rc cmp=$n $s recdist=$all md5=$(md5sum < $o/ours.uhdm | cut -c1-8)"
