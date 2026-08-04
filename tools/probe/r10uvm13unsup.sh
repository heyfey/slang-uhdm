#!/bin/bash
# r10uvm13unsup.sh <Test> — re-emit one UVM-4 test with SLANG_UHDM_UNSUP_LOC=1
# and print the LOCATED unsupported-construct report.
set -u
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_45cf267a-793-1
T=$1
D=$(ls -d /tmp/r10uvm11_slw/default/$T-* 2>/dev/null | head -1)
ARGS=$(sed -n 's/^slang:   //p' "$D/cmds.txt" | cut -d' ' -f2- |
       sed "s#-o [^ ]*#-o /tmp/r10uvm13_unsup_$T.uhdm#")
case $T in
  BuildUVMPkg) TD=/home/heyfey/git-repos/Surelog/third_party/tests/BuildUVMPkg;;
  *)           TD=/home/heyfey/git-repos/Surelog/third_party/tests/$T;;
esac
cd "$TD" || exit 1
SLANG_UHDM_UNSUP_LOC=1 eval "$W/build/slang-uhdm $ARGS" 2>&1 >/dev/null
