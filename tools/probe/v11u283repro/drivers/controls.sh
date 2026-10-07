#!/bin/bash
# v11u283 controls.sh <out> <case-dir list file>: every listed tools/probe case (one case dir per line, relative to
# tools/probe) in both views on pristine and the fix (case.sh lines, exit codes included), three in parallel. The list
# is filtered by $FENCED (word boundary) before any case is opened.
[ -n "$FENCED" ] && [ -n "$B" ] || { echo "controls.sh: source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")/.." && pwd); out=$1; lst=$2; : > $out
fre=$(echo $FENCED | tr ' ' '|')
grep -vwE "$fre" $lst | sed "s#^\./##; s#^#$H/../#" |
  while read c; do for el in 0 1; do echo "$el $c pristine $B/pristine"; echo "$el $c fix $B/fix"; done; done |
  xargs -P 3 -L 1 bash -c 'EL=$0 '"$H"'/drivers/case.sh $1 $2 $3' >> $out
