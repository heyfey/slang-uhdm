#!/bin/bash
# v11u245: gridfix.sh <outfile> <case dirs...>: every case in both views on the fix binary, fix + R11V245_OFF, fix + each
# R11V245_* switch and fix + R11U245_OFF; one case.sh line per run (exit code included). Needs drivers/env.sh sourced.
[ -n "$FENCED" ] && [ -n "$B" ] || { echo "gridfix.sh: source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")/.." && pwd); out=$1; shift; : > $out
for c in "$@"; do
  for el in 0 1; do
    EL=$el $H/drivers/case.sh $c fix $B/fix >> $out
    EL=$el $H/drivers/case.sh $c fixVOFF $B/fix R11V245_OFF=1 >> $out
    EL=$el $H/drivers/case.sh $c fixUOFF $B/fix R11U245_OFF=1 >> $out
    for s in R11V245_GENVAR_OFF R11V245_ALIASEDLIST_OFF; do EL=$el $H/drivers/case.sh $c "fix-$s" $B/fix $s=1 >> $out; done
  done
done
