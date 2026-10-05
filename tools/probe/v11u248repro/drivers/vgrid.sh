#!/bin/bash
# v11u248 (adversarial verification of r11u248): vgrid.sh <outfile> [casedir-glob-root]: every case under the given
# cases/ root (default this repro's) in both views on pristine, law, fix, fix + R11U248_OFF, fix + R11V248_OFF and
# fix + each switch (the four laws' and the fix's); one case.sh line per run (exit code included), three in
# parallel. Needs drivers/env.sh sourced ($B with pristine, law, fix; $S; $FENCED). Paths filtered by $FENCED first.
[ -n "$FENCED" ] && [ -n "$B" ] || { echo "vgrid.sh: source drivers/env.sh" >&2; exit 2; }
for t in pristine law fix; do [ -x "$B/$t" ] || { echo "vgrid.sh: $B/$t not executable" >&2; exit 2; }; done
H=$(cd "$(dirname "$0")/.." && pwd); out=$1; root=${2:-$H/cases}; : > $out
SW="R11U248_CLONEDOTBASE_OFF R11U248_WITHCHAIN_OFF R11U248_CLONEPROPSTR_OFF R11U248_PAREDUCE_OFF R11V248_ELABNEAREST_OFF"
find $root \( -name dut.sv -o -name dut.v \) | sed 's#/dut\.s\?v$##' | sort -u | grep -vwE "$FENCE_RE" |
  while read c; do for el in 0 1; do
    echo "$el $c pristine $B/pristine"; echo "$el $c law $B/law"; echo "$el $c fix $B/fix"
    echo "$el $c fixOFF $B/fix R11U248_OFF=1"; echo "$el $c fixVOFF $B/fix R11V248_OFF=1"
    for s in $SW; do echo "$el $c fix-$s $B/fix $s=1"; done
  done; done | xargs -P 3 -L 1 bash -c 'EL=$0 '"$H"'/drivers/case.sh $1 $2 $3 $4' >> $out
