#!/bin/bash
# v11u228: gridv.sh <out> <case dir>... : every case in both views under pristine (P), r11u228's law binary (L), the
# verified binary (X), X under R11U228_OFF (XO: must be P's bytes), X under R11V228_OFF (XV: must be L's bytes), and X
# with each refinement switch dropped alone (I = R11V228_ROOTINST_OFF, S = R11V228_ROOTSHAPE_OFF).
H="$(cd "$(dirname "$0")" && pwd)"; . "$H/env.sh" || exit 2
OUT=$1; shift; : > $OUT
for b in law pristine fix; do [ -x "$B/$b" ] || { echo "gridv: $B/$b missing" >&2; exit 2; }; done
for c in "$@"; do
  for el in 0 1; do
    r() { EL=$el bash $H/case.sh $c "$@"; }
    p=$(r P $B/pristine); l=$(r L $B/law); x=$(r X $B/fix); xo=$(r XO $B/fix R11U228_OFF=1); xv=$(r XV $B/fix R11V228_OFF=1)
    i=$(r I $B/fix R11V228_ROOTINST_OFF=1); s=$(r S $B/fix R11V228_ROOTSHAPE_OFF=1)
    f() { echo "$1" | awk '{for(i=1;i<=NF;i++) if ($i ~ /^(cmp|strict|md5|rc)=/ || $i ~ /FAIL/) printf "%s ", $i}'; }
    echo "$(echo "$p" | awk '{print $1}') | P $(f "$p")| L $(f "$l")| X $(f "$x")| XO $(f "$xo")| XV $(f "$xv")| I $(f "$i")| S $(f "$s")" >> $OUT
  done
done
