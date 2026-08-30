#!/usr/bin/env bash
# r10uvm163 — the GATE RUNNER, one place so every number in GATES.r10uvm163.txt
# was produced by a script that can be re-run.  MEASUREMENT ONLY.
#
#   usage: PRIS=.. PATCHED=.. WDP=<pristine workdir root> WDQ=<patched> \
#          REPO=<worktree> gates163.sh
#
# It asserts, and PRINTS, in this order:
#   1. both binaries' md5s;
#   2. the golden dump tests on EACH binary with SLANG_UHDM exported to it, and
#      the /bin/false negative control (a harness that silently defaults to the
#      MAIN-TREE binary is RESUME.md §9's first harness trap);
#   3. the cmds.txt BINARY AUDIT for both sweep workdirs, by absolute PATH —
#      not by the string "slang-uhdm", which also matches the goldens cache;
#   4. the verify_golden STATUS HISTOGRAM of each patched CSV, so an rc=139
#      SEGFAULT wearing a SLANG_REJECT label is visible;
#   5. ct8rows over both corpora, both modes, against the committed baselines
#      AND against this pass's own pristine control CSVs.
set -u
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
WDP=${WDP:?}; WDQ=${WDQ:?}; REPO=${REPO:?}
echo "== 1. binaries"; md5sum "$PRIS" "$PATCHED"
echo "== 2. golden dump tests"
for B in "$PRIS" "$PATCHED"; do
  p=$(SLANG_UHDM=$B bash "$REPO/tests/check_goldens.sh" | grep -c '^PASS'; true)
  f=$(SLANG_UHDM=$B bash "$REPO/tests/check_goldens.sh" | grep -c '^FAIL'; true)
  echo "   $(basename "$B") PASS=$p FAIL=$f"
done
echo "   negative control (/bin/false) FAIL=$(SLANG_UHDM=/bin/false bash "$REPO/tests/check_goldens.sh" | grep -c '^FAIL'; true)"
echo "== 3. cmds.txt binary audit (by absolute path)"
for W in "$WDP/sl" "$WDP/u2r" "$WDQ/sl" "$WDQ/u2r"; do
  [ -d "$W" ] || { echo "   MISSING $W"; continue; }
  n=$(find "$W" -name cmds.txt | wc -l)
  echo "   $W  cmds=$n  binaries: $(find "$W" -name cmds.txt -exec grep -ohE '/[^ ]*\.bin|/[^ ]*build/slang-uhdm' {} + | sort -u | tr '\n' ' ')"
done
echo "== 4. status histograms (patched)"
for C in "$WDQ/sl.csv" "$WDQ/u2r_tf.csv" "$WDQ/u2r_def.csv"; do
  [ -f "$C" ] || { echo "   MISSING $C"; continue; }
  echo "   $(basename "$C"): $(awk -F, 'NR>1{print $3}' "$C" | sort | uniq -c | tr '\n' ' ')"
done
echo "== 5. ct8rows"
CT8=$REPO/tools/probe/r10oth8repro/ct8rows.sh
bash "$CT8" "$REPO/results/golden_surelog.csv"   "$WDQ/sl.csv"     | tail -1
bash "$CT8" "$WDP/sl.csv"                        "$WDQ/sl.csv"     | tail -1
bash "$CT8" "$REPO/results/gate_uhdm2rtlil.csv"  "$WDQ/u2r_tf.csv" | tail -1
bash "$CT8" "$WDP/u2r_tf.csv"                    "$WDQ/u2r_tf.csv" | tail -1
bash "$CT8" "$WDP/u2r_def.csv"                   "$WDQ/u2r_def.csv"| tail -1
