#!/bin/bash
# grid228.sh <out> <case dir>... : every case in both views under pristine (P), the law binary (L), the law binary
# under R11U228_OFF (O), and the law binary with each switch dropped alone (M = R11U228_MEMROOTFOLD_OFF,
# V = R11U228_PVSIZE_OFF, N = R11U228_SIZEBITNET_OFF). One line per case-view: verdicts (cmp, strict) and md5s.
H="$(cd "$(dirname "$0")" && pwd)"; . "$H/env.sh" || exit 2
OUT=$1; shift; : > $OUT
[ -x "$B/law" ] && [ -x "$B/pristine" ] || { echo "grid: binaries missing" >&2; exit 2; }
for c in "$@"; do
  for el in 0 1; do
    r() { EL=$el bash $H/case.sh $c "$@"; }
    p=$(r P $B/pristine); l=$(r L $B/law); o=$(r O $B/law R11U228_OFF=1)
    m=$(r M $B/law R11U228_MEMROOTFOLD_OFF=1); v=$(r V $B/law R11U228_PVSIZE_OFF=1); n=$(r N $B/law R11U228_SIZEBITNET_OFF=1)
    f() { echo "$1" | awk '{for(i=1;i<=NF;i++) if ($i ~ /^(cmp|strict|md5)=/ || $i ~ /FAIL/) printf "%s ", $i}'; }
    echo "$(echo "$p" | awk '{print $1}') | P $(f "$p")| L $(f "$l")| O $(f "$o")| M $(f "$m")| V $(f "$v")| N $(f "$n")" >> $OUT
  done
done
