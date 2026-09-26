#!/bin/bash
# obdump.sh <case> <tag>: order-blind uhdm-dump distance golden vs ours (paths/ids normalised)
source /tmp/v11u176_env.sh
C=$(echo $1 | sed 's|/|__|g'); O=/tmp/v11u176_scr/caseout/$C.$2
G=$(readlink -f /tmp/v11u176_cases/$1); FILES=$( [ -f $G/files ] && cat $G/files || echo dut.sv )
KEY=$(cd $G && cat $FILES | sha1sum | cut -c1-16)-$(echo "$FILES" | tr '\n' ' ' | sha1sum | cut -c1-6)
norm(){ sed -E 's/, id:[0-9]+//; s#/[^ ,:]*/([^/ ,:]+\.s?v)#\1#g; s/^ +//' ; }
[ -f $O/gold.dump ] || $UHDM_DUMP /tmp/v11u176_gold/$KEY/golden.uhdm 2>/dev/null | norm | sort > $O/gold.dump
$UHDM_DUMP $O/ours.uhdm 2>/dev/null | norm | sort > $O/ours.dump
echo "$1 $2 cmplines=$(wc -l < $O/cmp.txt) ob=$(comm -3 $O/gold.dump $O/ours.dump | wc -l) oursNotGold=$(comm -13 $O/gold.dump $O/ours.dump | wc -l) goldNotOurs=$(comm -23 $O/gold.dump $O/ours.dump | wc -l)"
