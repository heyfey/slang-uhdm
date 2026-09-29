#!/bin/bash
# r11u230map: the pristine gate sweep ($SP, all four stages) and the landing-off state sweeps for the away census
# (section 9): the HEAD binary under one landing's switches ($B/st<k>.sh wrappers: exec env <switches> $B/slang-uhdm),
# probe + both corpora, workdir $SWPFX<k> (names of equal length, as byteverify needs), one after the other.
# usage: statesweeps.sh <k>...   env: SWPFX SP (and env.sh's)
. "$(dirname "$0")/env.sh"
[ -x "$B/slang-uhdm" ] || { echo "statesweeps.sh: $B/slang-uhdm not executable" >&2; exit 2; }
( cd "$REPO" && SLANG_UHDM=$B/slang-uhdm tests/sweep.sh --jobs 3 --workdir ${SP:?} ) > $SP.log 2>&1; echo "SWEEP_RC=$?" >> $SP.log
for s in "$@"; do
  [ -x "$B/st$s.sh" ] || { echo "statesweeps.sh: $B/st$s.sh not executable" >&2; exit 2; }
  ( cd "$REPO" && SLANG_UHDM=$B/st$s.sh tests/sweep.sh --jobs 3 --corpus "probe surelog uhdm2rtlil" --workdir ${SWPFX:?}$s ) > ${SWPFX}$s.log 2>&1
  echo "SWEEP_RC=$?" >> ${SWPFX}$s.log
done
