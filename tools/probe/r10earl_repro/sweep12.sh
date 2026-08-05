#!/bin/bash
# usage: sweep4.sh <corpus> <mode> <filter> <tag> [jobs]
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_5ff5e790-346-1
export SLANG_UHDM=$W/build/slang-uhdm
C=$1; M=$2; F=$3; T=$4; J=${5:-1}
cd "$W" || exit 1
if [ -n "$F" ]; then
  timeout 3000 python3 scripts/verify_golden.py --corpus "$C" --mode "$M" \
    --filter "$F" --out "/tmp/r10earl12_$T.csv" --workdir "/tmp/r10earl12_${T}w" --jobs "$J"
else
  timeout 3000 python3 scripts/verify_golden.py --corpus "$C" --mode "$M" \
    --out "/tmp/r10earl12_$T.csv" --workdir "/tmp/r10earl12_${T}w" --jobs "$J"
fi
