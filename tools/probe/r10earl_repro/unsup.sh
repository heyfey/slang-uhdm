#!/bin/bash
# Re-run the Earlgrey_0_1 slang command line with the unsupported-locator on.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_668885c7-a36-1
D=$(ls -d /tmp/r10earl2_ew/default/Earlgrey_0_1-* 2>/dev/null | head -1)
[ -z "$D" ] && { echo "no workdir"; exit 1; }
CMD=$(grep '^slang:' "$D/cmds.txt" | sed 's/^slang: *//')
SRC=$(grep -o '\-f [^ ]*' <<<"$CMD" | head -1 | cut -d' ' -f2)
echo "cmd: $CMD"
cd "$(dirname "$(find /home/heyfey/git-repos/Surelog/third_party/tests/Earlgrey_0_1 -name "$SRC" | head -1)")" || exit 1
pwd
SLANG_UHDM_UNSUP_LOC=1 $CMD > /tmp/r10earl2_unsup.out 2> /tmp/r10earl2_unsup.err
echo "rc=$?"
wc -l /tmp/r10earl2_unsup.err
