#!/bin/bash
# r10bbp10run: run slang-uhdm on BlackBePipeInt directly (same argv the
# harness builds) with the probe env vars, capturing stderr instrumentation.
#   usage: r10bbp10run.sh <out-uhdm> <stderr-log>
W=${W:-/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_705b1d72-cf3-1}
O=${1:-/tmp/r10bbp10_run/dbg.uhdm}
E=${2:-/tmp/r10bbp10_dbg.txt}
mkdir -p "$(dirname "$O")"
cd /home/heyfey/git-repos/Surelog/tests/BlackBePipeInt || exit 1
timeout 900 "$W/build/slang-uhdm" dut.sv --single-unit -o "$O" 2> "$E"
echo "rc=$?"
wc -l "$E"
