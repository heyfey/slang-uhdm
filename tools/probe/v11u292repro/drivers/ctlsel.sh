#!/bin/bash
# v11u292 ctlsel.sh <pristine bin> <law bin> <out> <case-list file> [jobs]: byte controls over a list of case dirs
# (paths relative to tools/probe; the list is filtered by $FENCED before any file is opened), both views, one line
# per case-view and binary: `<case> <view> <pristine|law> rc=.. cmp=.. <strict> md5=..` (ctlsum.py reads it).
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "ctlsel.sh: FENCED unset" >&2; exit 2; }
H=$(cd "$(dirname "$0")" && pwd); T=$(cd "$H/../.." && pwd)
P=$1; L=$2; O=$3; LIST=$4; J=${5:-3}
FR="\\b($(echo $FENCED | tr ' ' '|'))\\b"
grep -vP "$FR" "$LIST" | while read -r d; do for v in d e; do echo "$d $v pristine $P"; echo "$d $v law $L"; done; done |
  xargs -P $J -L 1 bash -c 'echo "$0 $1 $2 $(bash '"$H"'/case.sh '"$T"'/$0 $3 $1 5)"' | sort > $O
wc -l < $O
