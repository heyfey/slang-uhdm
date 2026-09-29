#!/bin/bash
# r11u222map: the landing-off state sweeps for the away census (section 8): the HEAD binary under one landing's
# switches ($B/st<k>.sh wrappers: exec env <switches> $B/slang-uhdm), probe + both corpora, workdir $SWPFX<k>
# (15-character names, as byteverify needs), one after the other.  usage: statesweeps.sh <k>...   env: SWPFX
. "$(dirname "$0")/env.sh"
for s in "$@"; do
  ( cd "$REPO" && SLANG_UHDM=$B/st$s.sh tests/sweep.sh --jobs 3 --corpus "probe surelog uhdm2rtlil" --workdir ${SWPFX:?}$s ) > ${SWPFX}$s.log 2>&1
  echo "SWEEP_RC=$?" >> ${SWPFX}$s.log
done
