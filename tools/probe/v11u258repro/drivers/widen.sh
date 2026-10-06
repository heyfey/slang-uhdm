#!/bin/bash
# v11u258 widen.sh <out> <dir>...: the widened byte controls. Every case under the given tools/probe dirs in both views
# on the three frozen binaries $B/pristine (tag P), $B/law (tag L) and $B/fix (tag F) through r11u258repro/drivers/case.sh,
# three in parallel; one case.sh line per case-view-binary, exit code included. Paths are listed first and filtered by
# $FENCED (word boundary) before any case is opened; fail-closed.
[ "$(echo $FENCED | wc -w)" = 4 ] && [ -n "$B" ] || { echo "widen.sh: source r11u258repro/drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")/../.." && pwd); out=$1; shift; : > $out
for b in pristine law fix; do [ -x "$B/$b" ] || { echo "widen.sh: $B/$b not executable" >&2; exit 2; }; done
fre=$(echo $FENCED | tr ' ' '|')
for d in "$@"; do find $H/$d \( -name dut.sv -o -name dut.v \) | sed 's#/dut\.s\?v$##'; done | sort -u | grep -vwE "$fre" |
  while read c; do for el in 0 1; do echo "$el $c"; done; done |
  xargs -P 3 -L 1 bash -c 'for t in P:pristine L:law F:fix; do EL=$0 '"$H"'/r11u258repro/drivers/case.sh $1 ${t%%:*} $B/${t#*:} | sed "s/^/${t%%:*} /"; done' >> $out
