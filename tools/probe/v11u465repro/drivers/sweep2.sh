#!/bin/bash
# sweep.sh: one five-stage sweep on the frozen law binary, workdir /tmp/v11u465sw2
source /tmp/v11u465_env.sh || exit 9
export SLANG_UHDM=/tmp/v11u465_bin/verified R11U465_TRACE=/tmp/v11u465_trace2
[ -x "$SLANG_UHDM" ] || exit 9
rm -rf /tmp/v11u465_trace2; mkdir -p /tmp/v11u465_trace2
cd /tmp/wt_v11u465 && bash tests/sweep.sh --jobs 3 --workdir /tmp/v11u465sw2 --corpus "probe surelog uhdm2rtlil downstream" > /tmp/v11u465_sweep2_corpus.log 2>&1
echo "CORPUS_RC=$?" >> /tmp/v11u465_sweep2_corpus.log
cd /home/heyfey/git-repos/slang-uhdm && bash tests/sweep.sh --jobs 3 --workdir /tmp/v11u465sw2 --corpus svtests > /tmp/v11u465_sweep2_svtests.log 2>&1
echo "SVTESTS_RC=$?" >> /tmp/v11u465_sweep2_svtests.log
