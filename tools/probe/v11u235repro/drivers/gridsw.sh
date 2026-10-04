#!/bin/bash
# v11u235: gridsw.sh <list> <out>: the law binary with each R11U235_<LAW>_OFF alone, both views (lines carry rc=).
H="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; D="$H/../../r11u235repro/drivers"
export B=${B:-/tmp/v11u235_bin} S=${S:-/tmp/v11u235_s}
. "$D/env.sh" || exit 2
[ -n "$FENCE_RE" ] || exit 2
grep -Ev "$FENCE_RE" $1 | xargs -P 3 -I{} bash -c '
 for el in 0 1; do for sw in VLOGKWSPAN VLOGBYTE ANCHORQUAL CLSENUMMEM UNITCLSAGGW; do
  EL=$el bash '"$D"'/case.sh {} X_$sw $B/law R11U235_${sw}_OFF=1
 done; done' > $2 2>&1
