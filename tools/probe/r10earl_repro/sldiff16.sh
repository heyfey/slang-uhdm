#!/bin/bash
# usage: sldiff15.sh <tag>  -> whole-row diff of a Surelog both-modes sweep
# against the committed baseline.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_1598db0f-a0c-1
T=$1
sort "$W/results/golden_surelog.csv" > /tmp/r10earl16_slbase.txt
sort "/tmp/r10earl16_sl_$T.csv" > /tmp/r10earl16_slnew_$T.txt
wc -l /tmp/r10earl16_slbase.txt /tmp/r10earl16_slnew_$T.txt
diff /tmp/r10earl16_slbase.txt /tmp/r10earl16_slnew_$T.txt
echo "sl diff rc=$?"
