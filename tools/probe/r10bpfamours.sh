#!/bin/bash
# r10bpfam: run OUR emitter on a purpose-built repro dir and dump it.
# Usage: r10bpfamours.sh <dir> [extra slang-uhdm args]
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_8a9f0e85-35c-1
D=$1; shift
cd "$D" || exit 1
$W/build/slang-uhdm t.sv --single-unit "$@" -o o.uhdm > o.log 2>&1
echo "exit=$?"
~/git-repos/UHDM/build/bin/uhdm-dump o.uhdm > o.txt 2>&1
wc -l o.txt
