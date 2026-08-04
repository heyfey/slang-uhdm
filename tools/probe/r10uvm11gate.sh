#!/bin/bash
# r10uvm11gate.sh <mode> <corpus> <filter> <tag> [jobs]
set -u
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_0818e3af-a35-1
export SLANG_UHDM=$W/build/slang-uhdm
M=$1; C=$2; F=$3; T=$4; J=${5:-4}
python3 $W/scripts/verify_golden.py --corpus $C --mode $M --filter "$F" \
  --out /tmp/r10uvm11_$T.csv --workdir /tmp/r10uvm11_${T}w --jobs $J
