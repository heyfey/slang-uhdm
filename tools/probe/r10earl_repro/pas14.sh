#!/bin/bash
# pas14.sh <witness-basename> [grep-filter]  -- paspan14.py on both sides.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_d6db6f8b-3b4-1
D=/tmp/r10earl14_rep/out_$1
F=${2:-.}
echo "### GOLDEN"
python3 "$W/tools/probe/r10earl_repro/paspan14.py" "$D/g.dump" | grep -E "$F"
echo "### OURS"
python3 "$W/tools/probe/r10earl_repro/paspan14.py" "$D/o.dump" | grep -E "$F"
