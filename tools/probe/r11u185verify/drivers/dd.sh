#!/bin/bash
# dd.sh <GW case dir> <tagA> <tagB> [golden-context-grep]: uhdm-dump of two states of one case (ids and directories
# stripped), their diff, and (optionally) the golden dump lines around a pattern -- the object-level reading behind a
# multiset STAGE1-AWAY / MIXED cell.  Cases only (grid scratch); fail-closed on $FENCED.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "dd.sh: source drivers/env.sh" >&2; exit 2; }
d=$1; a=$2; b=$3
for n in $FENCED; do echo "$d" | grep -qw "$n" && { echo "fenced refused"; exit 3; }; done
T=/tmp/r11u185_dd; mkdir -p $T; k=$(echo $d | tr / _)
g=$(ls $d/gold_*/golden.uhdm | head -1)
for t in $a $b golden; do f=$d/$t.uhdm; [ $t = golden ] && f=$g; $UHDM_DUMP $f 2>/dev/null | sed -E 's/, id:[0-9]+//; s#/[^ ,:()]*/##g' | tail -n +2 > $T/$k.$t; done
diff $T/$k.$a $T/$k.$b
[ -n "$4" ] && { echo "=== golden around /$4/"; grep -n -A${CTX:-12} -- "$4" $T/$k.golden | head -${MAXL:-60}; }
