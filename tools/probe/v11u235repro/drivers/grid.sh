#!/bin/bash
# v11u235: grid.sh <list of case dirs> <out file>: every case in both views under pristine (P), law (L),
# law with R11U235_OFF+R11U234_OFF (O) and law with R11U235_OFF (O5), through r11u235repro/drivers/case.sh
# (lines carry rc=). $B holds the frozen binaries (default /tmp/v11u235_bin), $S the case store.
# Paths resolve from this checkout; fail-closed on $FENCED (env.sh).
H="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; D="$H/../../r11u235repro/drivers"
export B=${B:-/tmp/v11u235_bin} S=${S:-/tmp/v11u235_s}
. "$D/env.sh" || exit 2
[ -n "$FENCE_RE" ] || exit 2
grep -Ev "$FENCE_RE" $1 | xargs -P 3 -I{} bash -c '
 for el in 0 1; do
  EL=$el bash '"$D"'/case.sh {} P $B/pristine
  EL=$el bash '"$D"'/case.sh {} L $B/law
  EL=$el bash '"$D"'/case.sh {} O $B/law R11U235_OFF=1 R11U234_OFF=1
  EL=$el bash '"$D"'/case.sh {} O5 $B/law R11U235_OFF=1
 done' > $2 2>&1
