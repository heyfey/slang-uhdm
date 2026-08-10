#!/bin/bash
# dbg19.sh -- re-run the Earlgrey_0_1 slang command line with extra env set,
# e.g. `R10E19_DBG=1 dbg19.sh`.  stdout -> /tmp/r10earl23_dbg.out,
# stderr -> /tmp/r10earl23_dbg.err (the instrumentation channel).
D=$(ls -d /tmp/r10earl23_e0w/default/Earlgrey_0_1-* 2>/dev/null | head -1)
[ -z "$D" ] && { echo "no workdir"; exit 1; }
CMD=$(grep '^slang:' "$D/cmds.txt" | sed 's/^slang: *//')
SRC=$(grep -o '\-f [^ ]*' <<<"$CMD" | head -1 | cut -d' ' -f2)
cd "$(dirname "$(find /home/heyfey/git-repos/Surelog/third_party/tests/Earlgrey_0_1 -name "$SRC" | head -1)")" || exit 1
pwd
$CMD > /tmp/r10earl23_dbg.out 2> /tmp/r10earl23_dbg.err
echo "rc=$?"
wc -l /tmp/r10earl23_dbg.err
