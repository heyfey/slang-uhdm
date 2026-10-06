#!/bin/bash
# (v11u263) quick.sh <out> <case dir>...: pristine and law in both views, one line per case-view-binary with rc=.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
out=$1; shift; : > $out
for c in "$@"; do for el in 0 1; do
  EL=$el bash $D/case.sh $c P $B/pristine | sed 's/^/P /' >> $out
  EL=$el bash $D/case.sh $c L $B/law | sed 's/^/L /' >> $out
done; done
