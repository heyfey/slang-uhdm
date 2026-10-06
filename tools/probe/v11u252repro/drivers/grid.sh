#!/bin/bash
# v11u252repro grid.sh <outfile> [casedir-glob-root]: every case under cases/ (or under $GRID_ROOT) in both views on
# pristine, law, law + R11U252_OFF and law + each switch (and with FIXBIN: fix, fix + R11V252_OFF, fix + R11U252_OFF,
# fix + each R11V252 switch); one case.sh line per run, exit code included.
# Needs drivers/env.sh sourced ($B, $S, $FENCED).
[ -n "$FENCED" ] && [ -n "$B" ] || { echo "grid.sh: source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")/.." && pwd); out=$1; : > $out
ROOT=${GRID_ROOT:-$H/cases}
SW="R11U252_DUPIMPVAL_OFF R11U252_CLONELVLOCAL_OFF R11U252_CLONEIDXSEL_OFF R11U252_CLONELVSCOPED_OFF R11U252_CLONERANDWITH_OFF R11U252_IMPCASTLOC_OFF R11U252_IMPREFLOC_OFF R11U252_TERNREFCHAIN_OFF R11U252_LAZYARITHLOC_OFF R11U252_MEMREADPARENT_OFF R11U252_PATBINLEFT_OFF R11U252_CONCATSELREAD_OFF ${EXTRA_SW}"
LB=${LAWBIN:-$B/law.bin}
for c in $(cd $ROOT && ls -d */* | sort); do
  for n in $FENCED; do echo "$c" | grep -qw "$n" && { echo "grid.sh: fenced path refused" >&2; exit 2; }; done
  for el in 0 1; do
    echo "$el $ROOT/$c pristine $B/pristine.bin"
    echo "$el $ROOT/$c law $LB"
    echo "$el $ROOT/$c lawOFF $LB R11U252_OFF=1"
    for s in $SW; do echo "$el $ROOT/$c law-$s $LB $s=1"; done
    [ -n "$FIXBIN" ] && { echo "$el $ROOT/$c fix $FIXBIN"; echo "$el $ROOT/$c fixVOFF $FIXBIN R11V252_OFF=1"; echo "$el $ROOT/$c fixUOFF $FIXBIN R11U252_OFF=1";
      for v in R11V252_CONCATSELPARAM_OFF R11V252_MEMREADPKG_OFF R11V252_DUPTYPEPARAM_OFF R11V252_CASTNESTCAT_OFF; do echo "$el $ROOT/$c fix-$v $FIXBIN $v=1"; done; }
  done
done | xargs -P ${GRID_JOBS:-2} -L 1 bash -c 'EL=$0 '"$H"'/drivers/case.sh "$@"' >> $out
