#!/bin/bash
# r11u236repro: the grid. For every case dir under cases/ (dut.sv), both views (EL=0 default, EL=1 -elabuhdm /
# --elabuhdm), run drivers/case.sh with: pristine ($B/pristine), law ($B/law), law with R11U236_OFF=1, and the law
# with each law's own switch. One line per run: `<case><_el> <tag> cmp=<rc> cmplines=<n> strict=<verdict> rc=<exit> md5=<8>`.
# usage: grid.sh <out file> [jobs]   (fail-closed on the fence through env.sh / case.sh)
set -u; HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 2
OUT=$1; J=${2:-2}
SW="PKGDEFSHARE ARITHPAREN HPIDXOWNER CONNIPSOWNER CLONERETTS NAMEDARGTS OPARGTS MIDSELBASESEL LEFTCOPYSHARE"
: > "$OUT"
for c in $(cd "$HERE/../cases" && find . -name dut.sv | sed 's#^\./##; s#/dut.sv$##' | sort); do
  for el in 0 1; do
    echo "EL=$el bash $HERE/case.sh $HERE/../cases/$c pri $B/pristine"
    echo "EL=$el bash $HERE/case.sh $HERE/../cases/$c law $B/law"
    echo "EL=$el bash $HERE/case.sh $HERE/../cases/$c off $B/law R11U236_OFF=1"
    for s in $SW; do echo "EL=$el bash $HERE/case.sh $HERE/../cases/$c off_$s $B/law R11U236_${s}_OFF=1"; done
  done
done | xargs -P "$J" -I{} bash -c '{}' >> "$OUT"
sort -o "$OUT" "$OUT"
echo "grid: $(wc -l < "$OUT") runs"
