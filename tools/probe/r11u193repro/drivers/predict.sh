#!/bin/bash
# r11u193: run the predictor over every database of a PRISTINE sweep workdir (surelog + uhdm2rtlil, both modes; probe),
# refusing the fenced rows by word boundary (FENCED from canaudit.sh, fail closed).  usage: predict.sh <pristine workdir> <out>
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 3
W=$1; O=$2; : > $O; skipped=0
for c in surelog uhdm2rtlil; do for m in default testflags; do for d in $W/$c/$m/*/; do d=${d%/}; row=$(basename $d); row=${row%-*}
  if r193_fenced "$row"; then skipped=$((skipped+1)); continue; fi
  [ -s $d/slang.uhdm ] || continue
  f=$($R193_BIN/${PREDICT:-predict} $d/slang.uhdm 2>/dev/null | tr '\n' ' '); [ -n "$f" ] && echo "$c $m $row $f" >> $O; done; done; done
for u in $W/probe/*.uhdm; do n=$(basename $u .uhdm); r193_fenced "$n" && { skipped=$((skipped+1)); continue; }
  f=$($R193_BIN/${PREDICT:-predict} $u 2>/dev/null | tr '\n' ' '); [ -n "$f" ] && echo "probe - $n $f" >> $O; done
echo "fenced_skipped=$skipped" >> $O
