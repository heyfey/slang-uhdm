#!/bin/bash
# r10uvm16acen.sh <Test> <substr> [ours|golden] — run r10uvm16a over one side.
set -u
W=${R10WT:-/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_20e4a997-bf7-1}
T=$1; SUB=$2; SIDE=${3:-golden}; O=${4:-/tmp/r10uvm16_m}
A=${R10A:-/tmp/r10uvm16_a}
if [ "$SIDE" = golden ]; then
  F=$(bash $W/tools/probe/r10uvm16g.sh $T)
else
  F=$O/$T.uhdm
fi
$A "$F" "$SUB"
