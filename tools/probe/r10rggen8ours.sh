#!/bin/bash
# r10rggen8ours: run slang-uhdm on a purpose-built repro; dump to /tmp/r10rggen8_ours.txt
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_f51a0e22-b08-1
D=$1; shift
F=$1; shift
cd "$D" || exit 1
$W/build/slang-uhdm --single-unit "$@" "$F" -o /tmp/r10rggen8_ours.uhdm \
  > /tmp/r10rggen8_ours.log 2>&1
echo "rc=$?"
$HOME/git-repos/UHDM/build/bin/uhdm-dump /tmp/r10rggen8_ours.uhdm > /tmp/r10rggen8_ours.txt 2>&1
echo "lines=$(wc -l < /tmp/r10rggen8_ours.txt)"
