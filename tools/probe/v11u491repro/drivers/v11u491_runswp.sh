#!/bin/bash
# usage: v11u491_runswp.sh <binary> <workdir> <tracedir>
B=$1; WD=$2; TR=$3
source /tmp/v11u491_drv/env.sh || exit 1
export SLANG_UHDM=$B
[ -x "$SLANG_UHDM" ] || { echo "no binary"; exit 1; }
PAT='sweep\.sh|svtests_matrix|verify_golden|check_probe|downstream_uhdm2rtlil|check_svtests'
n=0
while pgrep -f "$PAT" | grep -v "^$$\$" > /dev/null; do n=$((n+1)); sleep 60; done
echo "quiet after $n checks: $(date)"
mkdir -p $TR; export R11U491_TRACE=$TR
cd /tmp/wt_v11u491 && bash tests/sweep.sh --jobs 3 --workdir $WD --corpus "probe surelog uhdm2rtlil downstream"; echo "corpus stages rc=$?"
cd /home/heyfey/git-repos/slang-uhdm && bash tests/sweep.sh --jobs 3 --workdir $WD --corpus svtests; echo "svtests stage rc=$?"
echo "done $(date)"
