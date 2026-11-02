#!/bin/bash
# v11u469: one five-stage gate on the law binary (four corpus stages from the verifier worktree,
# the sv-tests stage through the main tree's tests/sweep.sh since the worktree's UVM folder is empty)
source /tmp/v11u469_env.sh
export SLANG_UHDM=/tmp/v11u469_bin/law
export R11U469_TRACE=/tmp/v11u469_trace
mkdir -p /tmp/v11u469_trace
cd /tmp/wt_v11u469 && bash tests/sweep.sh --jobs 3 --workdir /tmp/v11u469_sw --corpus "probe surelog uhdm2rtlil downstream" > /tmp/v11u469_sweep_corpus.log 2>&1
echo "CORPUS_RC=$?" >> /tmp/v11u469_sweep_corpus.log
cd /home/heyfey/git-repos/slang-uhdm && bash tests/sweep.sh --jobs 3 --workdir /tmp/v11u469_sw --corpus svtests > /tmp/v11u469_sweep_svtests.log 2>&1
echo "SVTESTS_RC=$?" >> /tmp/v11u469_sweep_svtests.log
