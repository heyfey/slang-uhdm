#!/bin/bash
# pdump.sh <name>: path-normalized uhdm-dump compare of law vs control probe db
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
n() { $D "$1" 2>&1 | tail -n +2 | sed -E 's#(/tmp/wt_v11u472|/home/heyfey/git-repos/slang-uhdm)/##g'; }
f=$1
if [ "${NEG:-}" = 1 ]; then o=/tmp/intr11u470/probe/r10earl_repro__qq.uhdm; else o=/tmp/intr11u470/probe/$f; fi
if diff -q <(n /tmp/v11u472_sw/probe/$f) <(n $o) >/dev/null; then echo "SAME $f"; else echo "DIFF $f"; fi
