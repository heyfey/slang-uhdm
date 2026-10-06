#!/bin/bash
# (r11u252: copied from r11u250repro/drivers; jobs in parallel, -P ${GRID_JOBS:-2})
# grid.sh <outfile>: every case under cases/ and decode/ in both views on pristine, law, law + R11U252_OFF and law +
# each switch; one line per run (case.sh's line, exit code included). Needs drivers/env.sh sourced ($B, $S, $FENCED).
[ -n "$FENCED" ] && [ -n "$B" ] || { echo "grid.sh: source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")/.." && pwd); out=$1; : > $out
SW="R11U252_DUPIMPVAL_OFF R11U252_CLONELVLOCAL_OFF R11U252_CLONEIDXSEL_OFF R11U252_CLONELVSCOPED_OFF R11U252_CLONERANDWITH_OFF R11U252_IMPCASTLOC_OFF R11U252_IMPREFLOC_OFF R11U252_TERNREFCHAIN_OFF R11U252_LAZYARITHLOC_OFF R11U252_MEMREADPARENT_OFF R11U252_PATBINLEFT_OFF R11U252_CONCATSELREAD_OFF"
LB=${LAWBIN:-$B/law.bin}
for c in $(cd $H && ls -d cases/*/* decode/*/* | sort); do
  for el in 0 1; do
    echo "$el $H/$c pristine $B/pristine.bin"
    echo "$el $H/$c law $LB"
    echo "$el $H/$c lawOFF $LB R11U252_OFF=1"
    for s in $SW; do echo "$el $H/$c law-$s $LB $s=1"; done
  done
done | xargs -P ${GRID_JOBS:-2} -L 1 bash -c 'EL=$0 '"$H"'/drivers/case.sh "$@"' >> $out
