#!/bin/bash
source /tmp/v11u458_env.sh
export SLANG_UHDM=/tmp/v11u458_bin/law/slang-uhdm
cd /tmp/wt_v11u458
R11U458_TRACE=/tmp/v11u458_swtrace bash tests/sweep.sh --jobs 3 --workdir /tmp/v11u458sw1 --corpus "probe surelog uhdm2rtlil downstream" > /tmp/v11u458_sweep_corpora.log 2>&1
echo "corpora rc=$?" >> /tmp/v11u458_sweep_corpora.log
cd /home/heyfey/git-repos/slang-uhdm
R11U458_TRACE=/tmp/v11u458_swtrace bash tests/sweep.sh --jobs 3 --workdir /tmp/v11u458sw1 --corpus svtests > /tmp/v11u458_sweep_svtests.log 2>&1
echo "svtests rc=$?" >> /tmp/v11u458_sweep_svtests.log
