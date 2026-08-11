#!/bin/bash
# r10uvm52repro/explainmover.sh — EXPLAIN a byte-verifier mover: dump the HEAD
# database and the POST database for one test/mode out of two workdirs and diff
# them, so "expect ONLY your target databases to move; explain any other mover"
# is answered with the actual object that changed rather than an assertion.
#
#   usage: explainmover.sh <head-workdir> <post-workdir> <mode> <Test> <outdir>
#
# GUARDS: both databases existence-checked (a missing one is NO_OUTPUT/exit 6,
# never a verdict); dumps must be non-empty; the ± count printed is CONTENT lines,
# i.e. `grep -c '^[-+]'` MINUS the 2 `diff -u` file-header lines.
# +2 BIAS FIXED AT INTEGRATION (found by the pass-50 verifier, confirmed by the
# master). uhdm-dump's FIRST LINE is the DATABASE PATH, which always differs
# between golden and ours, so it contributes one `-` and one `+` to every
# `diff -u`. Drivers that reported `grep -c '^[-+]'` minus 2 (subtracting only
# the ---/+++ headers) were therefore over-counting content by EXACTLY 2. Master
# verified on a real arm: raw 48, raw-2 = 46, TRUE content = 44. Both dumps are
# now piped through `sed '1d'` -- the same thing tests/check_goldens.sh already
# does -- so every figure from this driver is real content.
set -u
HW=${1:?head workdir}
PW=${2:?post workdir}
MODE=${3:?mode}
T=${4:?test}
OUT=${5:?outdir}
HD=$(echo "$HW/$MODE/$T"-*/slang.uhdm | head -1)
PD=$(echo "$PW/$MODE/$T"-*/slang.uhdm | head -1)
[ -f "$HD" ] || { echo "NO_OUTPUT: head db absent ($HD)"; exit 6; }
[ -f "$PD" ] || { echo "NO_OUTPUT: post db absent ($PD)"; exit 6; }
mkdir -p "$OUT" || exit 1
uhdm-dump "$HD" | sed 's#/home/[^ ,]*/##g' | sed '1d' > "$OUT/head.dump"
uhdm-dump "$PD" | sed 's#/home/[^ ,]*/##g' | sed '1d' > "$OUT/post.dump"
[ -s "$OUT/head.dump" ] && [ -s "$OUT/post.dump" ] || {
  echo "NO_OUTPUT: a dump is empty"; exit 6; }
RAW=$(diff -u "$OUT/head.dump" "$OUT/post.dump" | grep -c '^[-+]')
echo "$T/$MODE  head=$(wc -l < "$OUT/head.dump") post=$(wc -l < "$OUT/post.dump") lines"
echo "  content +/- = $((RAW-2))   (raw grep -c '^[-+]' = $RAW, which counts the 2 diff -u header lines)"
diff -u "$OUT/head.dump" "$OUT/post.dump" > "$OUT/dump.diff"
echo "  diff at $OUT/dump.diff"
