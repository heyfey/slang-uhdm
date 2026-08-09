#!/bin/bash
# usage: sldiff15.sh <tag>  -> whole-row diff of a Surelog both-modes sweep
# against the committed baseline.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_4f18c51a-913-1
T=$1
sort "$W/results/golden_surelog.csv" > /tmp/r10earl15_slbase.txt
sort "/tmp/r10earl15_sl_$T.csv" > /tmp/r10earl15_slnew_$T.txt
wc -l /tmp/r10earl15_slbase.txt /tmp/r10earl15_slnew_$T.txt
diff /tmp/r10earl15_slbase.txt /tmp/r10earl15_slnew_$T.txt
echo "sl diff rc=$?"
