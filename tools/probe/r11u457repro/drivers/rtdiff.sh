#!/bin/bash
# rtdiff.sh <case dir> <tag>: ref_typespec owner path -> actual + actual's vpiInstance, golden vs ours (sorted multiset diff)
T=${RTINST:-/tmp/r11u457_tools/rtinst}; [ -x "$T" ] || { echo "no rtinst"; exit 2; }
D=$(dirname $0); c=$(cd $1 && pwd); key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
diff <($T $($D/goldpath.sh $c) | sort) <($T /tmp/r11u457_scr/out/$key/$2/ours.uhdm | sort)
