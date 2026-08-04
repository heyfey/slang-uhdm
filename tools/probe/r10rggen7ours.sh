#!/bin/bash
# r10rggen7ours: run slang-uhdm on a repro and dump our UHDM (text).
# usage: r10rggen7ours.sh <dir> <file.sv> [extra slang-uhdm args]
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_72a14877-cd1-1
D=$1; shift
F=$1; shift
cd "$D" || exit 1
$W/build/slang-uhdm --single-unit "$@" "$F" -o /tmp/r10rggen7_ours.uhdm \
  > /tmp/r10rggen7_ours.log 2>&1
echo "rc=$?"
tail -3 /tmp/r10rggen7_ours.log
$HOME/git-repos/UHDM/build/bin/uhdm-dump /tmp/r10rggen7_ours.uhdm > /tmp/r10rggen7_ours.txt 2>&1
wc -l /tmp/r10rggen7_ours.txt
