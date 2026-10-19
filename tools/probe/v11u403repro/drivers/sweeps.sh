#!/bin/bash
. /tmp/v11u403_scr/env.sh
export SVTESTS_ROOT=/home/heyfey/git-repos/sv-tests
for t in P L; do
  if [ $t = P ]; then export SLANG_UHDM=/tmp/v11u403_pristine.bin; W=/tmp/v11u403_wdP; WT=/tmp/wt_v11u403pris; else export SLANG_UHDM=/tmp/v11u403_law.bin; W=/tmp/v11u403_wdL; WT=/tmp/wt_v11u403; fi
  [ -x "$SLANG_UHDM" ] || exit 9
  mkdir -p $W
  ( cd $WT && R11U403_TRACE=$W/trace bash tests/sweep.sh --jobs 3 --workdir $W --corpus "probe surelog uhdm2rtlil downstream" > $W/sweep.log 2>&1; echo "corpus rc=$?" >> $W/sweep.log )
done
echo ALLDONE
