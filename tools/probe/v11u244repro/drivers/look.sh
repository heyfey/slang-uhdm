#!/bin/bash
# look.sh <casedir> <grep-pattern> [tags]: strictcmp_x self-dump records (depth type name defname rawfullname line:col) of golden/pristine/law matching a pattern
# (v11u244) needs $B (the binaries directory holding strictcmp_x) and $FENCED; casedir in case.sh layout under $S/g
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "look.sh: FENCED must hold the four names (drivers/env.sh)" >&2; exit 2; }
c=$1; pat=$2; tags=${3:-"gold pristine law"}
for t in $tags; do u=$c/$t.uhdm; [ $t = gold ] && u=$(ls $c/gold_*/golden.uhdm); ${SCX:-$B/strictcmp_x} --max 0 --dump-a ${TMPDIR:-/tmp}/look.$$.rec --dump-b /dev/null $u $u >/dev/null 2>&1
echo "== $t"; awk -F'\t' '{x=$15; sub(/\x1f.*/,"",x); print NR": "$1,$2,$3,$4,"fn="x,$7":"$8"-"$9":"$10}' ${TMPDIR:-/tmp}/look.$$.rec | grep -E "$pat" | head -${N:-40}; done
