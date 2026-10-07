#!/bin/bash
# v11u275 gridv.sh <out> <case dir>... : every case in both views on P (pristine), L (law), F (the verified binary),
# FV (F + R11V275_OFF: must give L's bytes), FU (F + R11U275_OFF: must give P's bytes) and FK (F +
# R11V275_KEEPACTUAL_OFF); one line per case-view-configuration carrying the exit code (rc=). Binaries from $B.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
for t in pristine law fix; do [ -x "$B/$t" ] || { echo "gridv.sh: $B/$t not executable" >&2; exit 2; }; done
out=$1; shift; : > $out
for c in "$@"; do
  for el in 0 1; do
    EL=$el bash $D/case.sh $c P $B/pristine | sed 's/^/P /' >> $out
    EL=$el bash $D/case.sh $c L $B/law | sed 's/^/L /' >> $out
    EL=$el bash $D/case.sh $c F $B/fix | sed 's/^/F /' >> $out
    EL=$el bash $D/case.sh $c FV $B/fix R11V275_OFF=1 | sed 's/^/FV /' >> $out
    EL=$el bash $D/case.sh $c FU $B/fix R11U275_OFF=1 | sed 's/^/FU /' >> $out
    EL=$el bash $D/case.sh $c FK $B/fix R11V275_KEEPACTUAL_OFF=1 | sed 's/^/FK /' >> $out
  done
done
