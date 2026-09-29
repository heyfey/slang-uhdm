#!/bin/bash
# r11u230map: byte movers of each landing-off state sweep against this map's pristine sweep ($SP): corpus databases by
# tools/probe/r11v75repro/byteverify.sh (SELFCHECK=1) over fence-filtered hard-link mirrors of equal name length
# (bvmirror.sh), probe databases by md5 (both sweeps ran from this checkout, so the embedded paths agree).
# usage: movers.sh <k>...   env: SWPFX SP (and env.sh's)
. "$(dirname "$0")/env.sh"
bash $DR/bvmirror.sh $SP ${SWPFX}bvP > /dev/null
for s in "$@"; do
  bash $DR/bvmirror.sh ${SWPFX}$s ${SWPFX}bv$s > /dev/null
  echo "== state $s: corpus"; SELFCHECK=1 bash $REPO/tools/probe/r11v75repro/byteverify.sh ${SWPFX}bv$s ${SWPFX}bvP 2>&1 | grep -E 'MOVER|SELFCHECK|PATH|databases'
  n=0; t=0
  for p in ${SWPFX}$s/probe/*.uhdm; do t=$((t+1)); b=$(basename $p); cmp -s $p $SP/probe/$b || { n=$((n+1)); echo "   PMOVER ${b%.uhdm}"; }; done
  echo "   probe MOVERS: $n / $t"
done
