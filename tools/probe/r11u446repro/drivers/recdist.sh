#!/bin/bash
# recdist.sh <casedir> <tag>: record distance golden vs ours on the canon walk
# WITH each typespec's vpiInstance (drivers/reccmp.cpp: uhdm-strictcmp's walk,
# the 14th column carrying I:<kind>:<name> for a typespec, stage 1 skipped by
# FORCE2): diff lines of the two record dumps, and of the instance column alone.
c=$(cd $1 && pwd); t=$2; RC=${RECCMP:-/tmp/r11u446_tools/sc2}
[ -x "$RC" ] || { echo "no reccmp $RC"; exit 2; }
h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12)
key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
g=/tmp/r11u446_scr/gold/$h/slpp_all/surelog.uhdm; o=/tmp/r11u446_scr/out/$key/$t/ours.uhdm
[ -f $g ] && [ -f $o ] || { echo "$key $t NOFILES"; exit; }
d=/tmp/r11u446_scr/rec/$key/$t; mkdir -p $d
FORCE2=1 $RC --dump-a $d/g.rec --dump-b $d/o.rec $g $o > /dev/null 2>&1
sed -i 's/#[TD]$//' $d/g.rec $d/o.rec
all=$(diff $d/g.rec $d/o.rec | grep -c '^[<>]')
ins=$(diff <(cut -f1,2,14 $d/g.rec) <(cut -f1,2,14 $d/o.rec) | grep -c '^[<>]')
echo "$key $t recdist=$all instdist=$ins"
