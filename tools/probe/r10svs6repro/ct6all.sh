#!/usr/bin/env bash
# r10svs6 — every arm, then the four-way totals.
#
#   usage: SLANG_UHDM=<binary under test> ./ct6all.sh [outroot]
#
# GUARDS: SLANG_UHDM has NO DEFAULT (a stale-main-tree-binary reading has burned
# this campaign more than once) and its md5 is printed once at the top; every arm
# that fails to produce a golden or an ours dump is reported as such rather than
# contributing zero cells.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
: "${SLANG_UHDM:?set SLANG_UHDM to the build under test}"
OUT=${1:-/tmp/r10svs6_arms}
echo "SLANG_UHDM=$SLANG_UHDM  md5=$(md5sum "$SLANG_UHDM" | cut -d' ' -f1)"
mkdir -p "$OUT" || exit 9
tot=0; eq=0; df=0; un=0
for a in b1_witness b2_elemkind b3_arraykind b4_qual b5_vif; do
    echo "================ ARM $a"
    "$HERE/ct6arm.sh" "$a.sv" "$OUT/$a" > "$OUT/$a.log" 2>&1
    rc=$?
    sed -n '1,6p' "$OUT/$a.log"
    if [ $rc -ne 0 ]; then echo "ARM FAILED rc=$rc (see $OUT/$a.log)"; continue; fi
    python3 "$HERE/ct6cells.py" "$OUT/$a/g.dump" "$OUT/$a/o.dump" > "$OUT/$a.cells"
    cat "$OUT/$a.cells"
    # The summary line ends `UNMEASURED(one side emits no object)=N`, which has
    # SPACES INSIDE THE KEY -- splitting on spaces put `side:` in $u and the
    # script died with `unbound variable`.  Read each number by its own key.
    read -r c e d u < <(sed -n 's/^CELLS=\([0-9]*\) EQ=\([0-9]*\) DIFFER=\([0-9]*\) .*=\([0-9]*\)$/\1 \2 \3 \4/p' "$OUT/$a.cells")
    tot=$((tot + c)); eq=$((eq + e)); df=$((df + d)); un=$((un + u))
done
echo "================ TOTALS over all arms"
echo "CELLS=$tot EQ=$eq DIFFER=$df UNMEASURED=$un"
echo "OUT=$OUT"
