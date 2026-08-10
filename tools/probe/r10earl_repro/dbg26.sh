#!/bin/bash
# dbg26.sh <ENVVAR> [grep-pattern] -- replay the Earlgrey slang command line
# with an env-gated trace enabled and grep the stderr.  The command line is the
# one verify_golden.py writes into the workdir's cmds.txt.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_12312157-e8d-1
V=${1:-R10E23_DIMDBG}
P=${2:-DIMDBG}
D=/home/heyfey/git-repos/Surelog/third_party/tests/Earlgrey_0_1/sim-icarus
cd "$D" || exit 1
env "$V=1" "$W/build/slang-uhdm" +define+SYNTHESIS \
  -f lowrisc_systems_top_earlgrey_0.1.scr --single-unit \
  -o /tmp/r10earl26_dbg.uhdm 2>&1 | grep "$P"
