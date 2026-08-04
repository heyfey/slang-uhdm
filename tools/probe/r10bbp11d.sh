#!/bin/bash
# r10bbp11d: run the worktree binary on BlackBePipeInt directly (the argv the
# harness builds for default mode) with instrumentation env vars passed
# through, capturing stderr.
#   usage: r10bbp11d.sh <out.uhdm> <stderr.log>
W=${W:-/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_03807e90-423-1}
O=${1:-/tmp/r10bbp11_run/dbg.uhdm}
E=${2:-/tmp/r10bbp11_dbg.txt}
mkdir -p "$(dirname "$O")"
cd /home/heyfey/git-repos/Surelog/tests/BlackBePipeInt || exit 1
timeout 1800 "$W/build/slang-uhdm" dut.sv --single-unit -o "$O" 2> "$E"
echo "rc=$?"
wc -l "$E"
