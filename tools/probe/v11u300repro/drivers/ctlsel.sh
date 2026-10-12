#!/bin/bash
# r11u300 ctlsel.sh <pristine bin> <law bin> <out> <list file>: controls.sh over an explicit list of case dirs
# (paths relative to tools/probe, one per line; the list is filtered by $FENCED before any file is opened),
# both views, one line per case-view and binary: `<case> <view> <pristine|law> rc=.. cmp=.. <strict> md5=..`.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "ctlsel.sh: FENCED unset" >&2; exit 2; }
H=$(cd "$(dirname "$0")" && pwd); T=$(cd "$H/../.." && pwd)
P=$1; L=$2; O=$3; F=$4
FR="\\b($(echo $FENCED | tr ' ' '|'))\\b"
grep -vP "$FR" "$F" | while read -r d; do [ -f "$T/$d/dut.sv" ] || continue; for v in d e; do echo "$d $v pristine $P"; echo "$d $v law $L"; done; done |
  xargs -P 3 -L 1 bash -c 'echo "$0 $1 $2 $(bash '"$H"'/case.sh '"$T"'/$0 $3 $1 5)"' | sort > $O
wc -l < $O
