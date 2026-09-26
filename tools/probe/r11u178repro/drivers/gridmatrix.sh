#!/bin/bash
# gridmatrix.sh <casedir>...: per case and mode (default, --elabuhdm), the strict verdict of the pristine binary,
# the law binary, and the law binary with each r11u178 switch off.  Uses grid.sh (golden per case and mode).
set -u; D=$(cd "$(dirname "$0")" && pwd)
L=/tmp/r11u178_bin/law178.bin; P=/tmp/r11u178_bin/pris.bin
v() { awk '{for(i=1;i<=NF;i++) if ($i ~ /^strict=/) {s=substr($i,8); sub(/_objects$/,"",s); print s}}'; }
printf '%-40s %-22s %-22s %-22s %-22s %-22s\n' case pristine law MIDIDX_OFF MIDIDXNAME_OFF PATUNQUAL_OFF
for c in "$@"; do for e in "" 1; do
  n=$(basename $(dirname $c))/$(basename $c)${e:+.elab}
  a=$(ELAB=$e bash $D/grid.sh $c $P pris | v); b=$(ELAB=$e bash $D/grid.sh $c $L law | v)
  x=$(ELAB=$e bash $D/grid.sh $c $L offA R11U178_MIDIDX_OFF=1 | v); y=$(ELAB=$e bash $D/grid.sh $c $L offB R11U178_MIDIDXNAME_OFF=1 | v)
  z=$(ELAB=$e bash $D/grid.sh $c $L offC R11U178_PATUNQUAL_OFF=1 | v)
  printf '%-40s %-22s %-22s %-22s %-22s %-22s\n' $n $a $b $x $y $z
done; done
