#!/bin/bash
# v11u296 ctllist.sh <pristine bin> <law bin> <out> <list file>: controls.sh over an explicit list of case dirs
# (relative to tools/probe), the list filtered by $FENCED before any file is opened; both views.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "ctllist.sh: FENCED unset" >&2; exit 2; }
H=$(cd "$(dirname "$0")" && pwd); T=$(cd "$H/../.." && pwd)
P=$1; L=$2; O=$3; FR="\\b($(echo $FENCED | tr ' ' '|'))\\b"
grep -vP "$FR" "$4" | while read -r d; do for v in d e; do echo "$d $v pristine $P"; echo "$d $v law $L"; done; done |
  xargs -P 3 -L 1 bash -c 'echo "$0 $1 $2 $(bash '"$H"'/case.sh '"$T"'/$0 $3 $1 5)"' | sort > $O
wc -l < $O
