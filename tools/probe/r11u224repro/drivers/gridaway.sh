#!/bin/bash
# gridaway.sh <grid.tsv>: the away census of every case-view the law binary MOVES without converting.  A judge-equal
# case-view: the record multiset census (golden & pristine records the law database lost; case.sh keeps the records
# as <tag>.a.rec / <tag>.b.rec); a stage-1 case-view: dumpaway.py's dump-line census.  Prints `<case-view> lost=<n>
# toward=<n>`, and the same with the two databases swapped (the positive control reads lost = the forward toward).
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
awk -F'\t' '$5=="bytes=moved" && substr($3,3)!="EQUAL" {print $1, substr($2,3)}' "$1" | while read cv pv; do
  W=$S/g/$cv
  if [ "$pv" = NOT_EQUAL_stage1 ]; then
    f=$(python3 $HERE/dumpaway.py $W/gold_*/golden.uhdm $W/P.uhdm $W/L.uhdm); r=$(python3 $HERE/dumpaway.py $W/gold_*/golden.uhdm $W/L.uhdm $W/P.uhdm)
    echo "$cv dump $f control:$r"
  else
    python3 - "$W" "$cv" <<'PY'
import sys, collections
W, cv = sys.argv[1:3]
ld = lambda f: collections.Counter('\t'.join(l.rstrip('\n').split('\t')[1:]) for l in open(f))
G = ld(W + '/P.a.rec'); P = ld(W + '/P.b.rec'); L = ld(W + '/L.b.rec')
lost = sum(((G & P) - L).values()); tow = sum(((G & L) - P).values())
print(f'{cv} records lost={lost} toward={tow} control:lost={tow} toward={lost}')
PY
  fi
done
