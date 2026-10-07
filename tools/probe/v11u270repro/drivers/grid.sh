#!/bin/bash
# v11u270 grid: grid.sh <out.txt> <casedir>...  For each case dir and both views (EL=0/1) runs
# the pristine binary (tag pris), the law binary (law), the law binary under R11U270_OFF (off) and under
# each extra "TAG=ENV" given in $EXTRA (space separated, e.g. "nofix=R11V270_OFF").
# Every line carries rc. Paths from drivers/env.sh (fail-closed on $FENCED); binaries $B/pris, $B/law.
H=$(cd "$(dirname "$0")" && pwd)
. $H/env.sh || exit 2
out=$1; shift
one() {
  c=$1; el=$2
  EL=$el bash $H/case.sh $c pris $B/pris
  EL=$el bash $H/case.sh $c law $B/law
  EL=$el bash $H/case.sh $c off $B/law R11U270_OFF=1
  for x in $EXTRA; do EL=$el bash $H/case.sh $c ${x%%=*} $B/law ${x#*=}=1; done
}
export -f one; export H EXTRA
for c in "$@"; do for el in 0 1; do echo "$c $el"; done; done | xargs -P ${P:-2} -n 2 bash -c 'one "$0" "$1"' > $out
sort -o $out $out
