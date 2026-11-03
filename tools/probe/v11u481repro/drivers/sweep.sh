#!/bin/bash
source /tmp/v11u481_env.sh || exit 1
export SLANG_UHDM=/tmp/v11u481_bin/law
export R11U481_TRACE=/tmp/v11u481_trace
mkdir -p $R11U481_TRACE
[ -x "$SLANG_UHDM" ] || exit 1
cd /tmp/wt_v11u481 && bash tests/sweep.sh --jobs 3 --workdir /tmp/v11u481_sw --corpus "probe surelog uhdm2rtlil downstream" > /tmp/v11u481_sweep4.log 2>&1
echo "four rc=$?" >> /tmp/v11u481_sweep4.log
cd /home/heyfey/git-repos/slang-uhdm && SVTESTS_ROOT=/home/heyfey/git-repos/sv-tests bash tests/sweep.sh --jobs 3 --workdir /tmp/v11u481_sw --corpus svtests > /tmp/v11u481_sweepsv.log 2>&1
echo "sv rc=$?" >> /tmp/v11u481_sweepsv.log
