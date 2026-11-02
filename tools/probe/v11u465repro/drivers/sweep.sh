#!/bin/bash
# sweep.sh: one five-stage sweep on the frozen law binary, workdir /tmp/v11u465sw1
source /tmp/v11u465_env.sh || exit 9
export SLANG_UHDM=/tmp/v11u465_bin/law R11U465_TRACE=/tmp/v11u465_trace
[ -x "$SLANG_UHDM" ] || exit 9
rm -rf /tmp/v11u465_trace; mkdir -p /tmp/v11u465_trace
cd /tmp/wt_v11u465 && bash tests/sweep.sh --jobs 3 --workdir /tmp/v11u465sw1 --corpus "probe surelog uhdm2rtlil downstream" > /tmp/v11u465_sweep_corpus.log 2>&1
echo "CORPUS_RC=$?" >> /tmp/v11u465_sweep_corpus.log
cd /home/heyfey/git-repos/slang-uhdm && bash tests/sweep.sh --jobs 3 --workdir /tmp/v11u465sw1 --corpus svtests > /tmp/v11u465_sweep_svtests.log 2>&1
echo "SVTESTS_RC=$?" >> /tmp/v11u465_sweep_svtests.log
