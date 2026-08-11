#!/usr/bin/env bash
# r10oth3 MOVER EXPLAINER.  For one surelog-corpus test, builds the database with
# BOTH binaries (PRISTINE_UHDM and SLANG_UHDM, into separate workdirs so neither
# overwrites the other) and reports, for each, the uhdm-dump diff SIZE against
# the same golden.  A byte mover inside an already-`differ` row is invisible to
# the whole-row CSV diff, so this is how such a mover is shown to move TOWARD
# golden rather than away from it.
#
#   usage: SLANG_UHDM=<patched> PRISTINE_UHDM=<pristine> ./mover.sh <TestName> [mode]
#
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.  Both env vars are
# REQUIRED: no default, because verify_golden.py:52 and check_goldens.sh:5 both
# fall back to the MAIN-TREE binary.
set -u
: "${SLANG_UHDM:?set SLANG_UHDM to the patched build}"
: "${PRISTINE_UHDM:?set PRISTINE_UHDM to the pristine-HEAD build}"
REPO=${REPO:-$(cd "$(dirname "$0")/../../.." && pwd)}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
T=$1
MODE=${2:-default}
D=/tmp/r10oth3_mover_$T
rm -rf "$D"; mkdir -p "$D" || exit 9
for tag in pristine patched; do
    bin=$PRISTINE_UHDM; [ $tag = patched ] && bin=$SLANG_UHDM
    SLANG_UHDM=$bin python3 "$REPO/scripts/verify_golden.py" --corpus surelog \
        --mode "$MODE" --filter "$T" --out "$D/$tag.csv" \
        --workdir "$D/wd_$tag" --jobs 1 > "$D/$tag.log" 2>&1
done
GC=$(grep -o '/home[^ )]*golden.uhdm' "$D"/wd_patched/*/*/cmds.txt 2>/dev/null | head -1)
if [ -z "$GC" ]; then
    GC=$(grep -o 'goldens/[0-9a-f]*' "$D"/wd_patched/*/*/cmds.txt | head -1)
    GC="$HOME/.cache/slang-uhdm-$GC/golden.uhdm"
fi
[ -f "$GC" ] || { echo "NO_GOLDEN ($GC)"; exit 6; }
"$DUMP" "$GC" 2>/dev/null | sed '1d' > "$D/g.dump"
for tag in pristine patched; do
    o=$(find "$D/wd_$tag" -name slang.uhdm | head -1)
    [ -f "$o" ] || { echo "$tag NO_OUTPUT"; exit 6; }
    "$DUMP" "$o" 2>/dev/null | sed '1d' > "$D/$tag.dump"
    diff -u "$D/g.dump" "$D/$tag.dump" > "$D/$tag.diff"
    # content lines only: subtract the two `diff -u` FILE HEADER lines
    n=$(grep -c '^[-+]' "$D/$tag.diff")
    echo "$T/$MODE  $tag: dump-diff content lines = $((n - 2))  hunks = $(grep -c '^@@' "$D/$tag.diff")  md5=$(md5sum "$o" | cut -c1-12)"
done
echo "  golden dump lines = $(wc -l < "$D/g.dump")"
echo "  WD=$D"
