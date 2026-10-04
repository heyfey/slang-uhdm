#!/bin/bash
# recs.sh <casedir> <tag> [EL=1 in env]: map 15's analyzer rows (drivers/rowclusters.py) for the case's golden vs <tag>'s
# database written by case.sh under $GW. Fail-closed on $FENCED.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "recs.sh: source drivers/env.sh (FENCED)" >&2; exit 2; }
: "${GW:?export GW}"
c=$(realpath $1); t=$2
for n in $FENCED; do echo "$c" | grep -qw "$n" && { echo "recs.sh: fenced path refused" >&2; exit 2; }; done
rel=$(echo $c | sed "s#.*/r11u234dec/cases/##; s#.*/tests/probe/#probe/#; s#.*/tools/probe/#tp/#")
ek=""; [ "${EL:-0}" = 1 ] && ek="_el"
w=$GW/$rel$ek; g=$(ls $w/gold_*/golden.uhdm 2>/dev/null | head -1)
[ -s "$g" ] && [ -s "$w/$t.uhdm" ] || { echo "recs.sh: no databases for $rel$ek $t" >&2; exit 2; }
python3 $(dirname "$0")/rowclusters.py $g $w/$t.uhdm $w/$t.rc "$rel$ek/$t"
