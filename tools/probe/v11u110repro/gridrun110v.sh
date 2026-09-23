#!/bin/bash
# gridrun110v.sh <out-root> <tag>=<bin> ... — runs r11u110's grid110.sh (golden + each binary,
# rc recorded, uhdm-cmp LHS golden) over this pass's break arms (brk/v1 v3 v4 v5 v6), the
# implementer's grids and the four control grids.  Switch variants are wrapper scripts that
# export one switch and exec the law binary (e.g. V11U110_FIX_OFF=1, R11U110_PORT_OFF=1).
OUT=${1:?out}; shift
P=$(cd "$(dirname "$0")/.." && pwd)
for gd in v11u110repro/brk/v1 v11u110repro/brk/v3 v11u110repro/brk/v4 v11u110repro/brk/v5 v11u110repro/brk/v6 \
          r11u110repro/grid/e1 r11u110repro/grid/f2 r11u110repro/grid/m2 \
          r11u108repro/grid v11u108repro/brk r11u107repro/grid v11u93b107repro/brk; do
  bash "$P/r11u110repro/grid110.sh" "$P/$gd" "$OUT/$(echo $gd | tr / _)" "$@" > "$OUT/$(echo $gd | tr / _).txt" 2>&1
done
