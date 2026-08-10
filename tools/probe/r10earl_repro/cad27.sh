#!/bin/bash
# cad25.sh <basename> [scope-substr] -- dump BOTH sides of a run25 witness and
# diff the ONE-LINE-PER-CONT_ASSIGN projection (ca25.py).  LHS(golden) is the
# `<` side, ours is `>`.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_469c0e7a-755-1
B=$1
S=${2:-}
D=/tmp/r10earl27_rep/out_$B
bash "$W/tools/probe/r10earl_repro/dmp25.sh" "$B" > /dev/null
python3 "$W/tools/probe/r10earl_repro/ca25.py" "$D/g.dump" "$S" \
  | grep -v 'L=<null>' > "$D/gca.txt"
python3 "$W/tools/probe/r10earl_repro/ca25.py" "$D/o.dump" "$S" \
  | grep -v 'L=<null>' > "$D/oca.txt"
echo "--- < = GOLDEN   > = OURS   ($D/{gca,oca}.txt)"
diff "$D/gca.txt" "$D/oca.txt"
echo "(rc=$?)"
