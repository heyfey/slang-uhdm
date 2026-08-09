#!/bin/bash
# earlrun16.sh [out.uhdm] [err] -- replay the Earlgrey_0_1 DEFAULT-mode slang
# command line DIRECTLY (no harness), from the directory its -f file lives in.
# This is the loop to use while decoding: ~40s per run instead of a sweep, and
# it is the only way to run the emitter under an env-gated instrumentation
# build (R10E16_* style getenv prints) without a golden re-generation.
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_1598db0f-a0c-1
OUT=${1:-/tmp/r10earl16_manual.uhdm}
ERR=${2:-/tmp/r10earl16_manual.err}
cd /home/heyfey/git-repos/Surelog/third_party/tests/Earlgrey_0_1/sim-icarus || exit 1
$W/build/slang-uhdm +define+SYNTHESIS -f lowrisc_systems_top_earlgrey_0.1.scr \
  --single-unit -o "$OUT" > /tmp/r10earl16_manual.out 2> "$ERR"
echo "rc=$? out=$OUT err=$ERR"
wc -l "$ERR"
