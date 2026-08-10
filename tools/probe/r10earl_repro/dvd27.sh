#!/bin/bash
# dvd25.sh <basename> [scope-substr] -- dump both sides of a run25 witness and
# diff the ONE-LINE-PER-DECLARATION projection (dv25.py).  `<` = GOLDEN.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_469c0e7a-755-1
B=$1
S=${2:-}
D=/tmp/r10earl27_rep/out_$B
bash "$W/tools/probe/r10earl_repro/dmp25.sh" "$B" > /dev/null
python3 "$W/tools/probe/r10earl_repro/dv25.py" "$D/g.dump" "$S" > "$D/gdv.txt"
python3 "$W/tools/probe/r10earl_repro/dv25.py" "$D/o.dump" "$S" > "$D/odv.txt"
echo "--- < = GOLDEN   > = OURS   ($D/{gdv,odv}.txt)"
diff "$D/gdv.txt" "$D/odv.txt"
echo "(rc=$?)"
