#!/bin/bash
# r11u286 (copied from r11u284repro; r11u284 copied from r11u282repro) controls.sh  <pristine bin> <law bin> <out> <repro dir>...: byte controls over earlier passes' case dirs
# (every dut.sv dir under each tools/probe/<repro dir>, path list filtered by $FENCED before any file is opened),
# both views, one line per case-view and binary: `<case> <view> <pristine|law> rc=.. cmp=.. <strict> md5=..`.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "controls.sh: FENCED unset" >&2; exit 2; }
H=$(cd "$(dirname "$0")" && pwd); T=$(cd "$H/../.." && pwd)
P=$1; L=$2; O=$3; shift 3
FR="\\b($(echo $FENCED | tr ' ' '|'))\\b"
for r in "$@"; do (cd $T && find $r -name dut.sv | sort); done | grep -vP "$FR" | sed 's#/dut.sv$##' |
  while read -r d; do for v in d e; do echo "$d $v pristine $P"; echo "$d $v law $L"; done; done |
  xargs -P 3 -L 1 bash -c 'echo "$0 $1 $2 $(bash '"$H"'/case.sh '"$T"'/$0 $3 $1 5)"' | sort > $O
wc -l < $O
