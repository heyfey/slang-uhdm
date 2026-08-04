#!/bin/bash
# r10rggen9ours: run slang-uhdm on a purpose-built repro; dump to /tmp/r10rggen9_ours.txt
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_e1b54aae-99d-1
D=$1; shift
F=$1; shift
cd "$D" || exit 1
$W/build/slang-uhdm --single-unit "$@" "$F" -o /tmp/r10rggen9_ours.uhdm \
  > /tmp/r10rggen9_ours.log 2>&1
echo "rc=$?"
$HOME/git-repos/UHDM/build/bin/uhdm-dump /tmp/r10rggen9_ours.uhdm > /tmp/r10rggen9_ours.txt 2>&1
echo "lines=$(wc -l < /tmp/r10rggen9_ours.txt)"
