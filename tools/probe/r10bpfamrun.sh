#!/bin/bash
# r10bpfam: single/multi test harness runner.  Usage: r10bpfamrun.sh <tag> <mode> <regex>
cd /home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_8a9f0e85-35c-1 || exit 1
export SLANG_UHDM=$PWD/build/slang-uhdm
TAG=$1; MODE=$2; RE=$3
rm -rf /tmp/r10bpfam_w$TAG
timeout 1200 python3 scripts/verify_golden.py --corpus surelog --mode "$MODE" \
  --filter "$RE" --out /tmp/r10bpfam_t$TAG.csv --workdir /tmp/r10bpfam_w$TAG --jobs "${4:-1}"
echo "---- results"
cat /tmp/r10bpfam_t$TAG.csv
