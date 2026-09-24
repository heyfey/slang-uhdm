#!/bin/bash
# mkfake.sh <repo> <dst>: a scratch repository holding <repo>'s scripts, its
# results/golden_probe.csv and a copy of tests/probe, so a case can be deleted,
# renamed, edited or added without touching the read-only tests/probe. The
# probe stage of tests/sweep.sh is exactly `check_probe.py --out` followed by
# `compare_results.py <csv> results/golden_probe.csv [--filter]`, run here by hand
# (the law-index check of sweep.sh needs git history, which the copy lacks).
set -eu; R=$1; D=$2
rm -rf $D; mkdir -p $D/results $D/tests
cp -r $R/scripts $D/scripts; cp $R/results/golden_probe.csv $D/results/; cp -r $R/tests/probe $D/tests/probe
