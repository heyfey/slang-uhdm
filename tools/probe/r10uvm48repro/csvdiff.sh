#!/bin/bash
# r10uvm48 (cloned from pass 46) (cloned from pass 45) (cloned from pass 44) — WHOLE-ROW diff of a sweep CSV against its committed baseline, both
# sides sorted so row order is not mistaken for a change.  Whole row INCLUDING
# the DUMP column, which is why SLANG_REJECT membership cannot change silently.
#   usage: csvdiff.sh <baseline.csv> <new.csv>
set -u
B=${1:?}
N=${2:?}
D=$(diff <(sort "$B") <(sort "$N"))
echo "baseline=$(wc -l < "$B") new=$(wc -l < "$N") difflines=$(printf '%s' "$D" | grep -c '^[<>]')"
printf '%s\n' "$D" | grep '^[<>]' | head -60
