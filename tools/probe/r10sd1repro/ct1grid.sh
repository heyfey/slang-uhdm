#!/usr/bin/env bash
# r10sd1 GRID DRIVER — one row per grid cell, GOLDEN and OURS side by side.
#
#   usage: SLANG_UHDM=<bin> ./ct1grid.sh <tag>
#
# Each `grid/bN_*.sv` is ONE cell and lives in its OWN FILE on purpose.  Arm
# a1_registry.sv put every cell in one file and the reading was WORTHLESS: every
# typedef of one generic class joins ONE Surelog typedef GROUP (pass-50 law 4 /
# § classNestedClassTdGroupNoAnchor54), so the package-scope cell became the
# group BASE and all nine class-scope cells were reported as clones of it.  The
# confound is recorded here because it cost a full measurement cycle and because
# a1 is kept in the directory as the refutation.
#
# The reading per cell is the PA STATE of the cell's `class_typespec`:
#   PA = carries BOTH vpiParameter and vpiParamAssign (the specialization)
#   -- = carries neither
# read from the object's FULL print (pacells.py), because uhdm-dump prints an
# object's body exactly once and every later appearance is a header line only.
#
# GUARDS:
#   * a cell whose golden side fails to build is printed SURELOG_FAIL and
#     COUNTED, never skipped -- a grid that reached nothing prints all-agree.
#   * SLANG_UHDM has NO DEFAULT (verify_golden.py and check_goldens.sh both
#     default it to the MAIN-TREE binary, which has burned this campaign).
#   * the golden PA reading is taken FIRST and independently of ours, so a
#     broken RHS cannot silently move the reference column.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
: "${SLANG_UHDM:?set SLANG_UHDM to the build under test}"
TAG=${1:?tag}
n=0; pa_g=0; pa_o=0; agree=0; disagree=0; failed=0
printf '%-24s %-8s %-8s %s\n' CELL GOLDEN OURS VERDICT
for f in "$HERE"/grid/b*.sv; do
    b=$(basename "$f" .sv)
    d=/tmp/r10sd1_${TAG}_$b
    out=$(SLANG_UHDM=$SLANG_UHDM "$HERE/ct1arm.sh" "grid/$b.sv" "$d" 2>&1)
    n=$((n + 1))
    if ! [ -s "$d/g.dump" ]; then
        printf '%-24s %-8s %-8s %s\n' "$b" SURELOG_FAIL - COUNTED-AS-FAILED
        failed=$((failed + 1)); continue
    fi
    G=$(python3 "$HERE/pacells.py" "$d/g.dump" --only-pa 2>/dev/null \
        | grep -cE "^PA .*(tidb|regb)")
    if [ -s "$d/o.dump" ]; then
        O=$(python3 "$HERE/pacells.py" "$d/o.dump" --only-pa 2>/dev/null \
            | grep -cE "^PA .*(tidb|regb)")
    else
        O=NO_OURS_DUMP
    fi
    v=DIFF
    [ "$G" = "$O" ] && v=SAME
    if [ "$v" = SAME ]; then agree=$((agree + 1)); else disagree=$((disagree + 1)); fi
    [ "$G" != 0 ] && pa_g=$((pa_g + 1))
    [ "$O" = 0 ] || pa_o=$((pa_o + 1))
    printf '%-24s %-8s %-8s %s\n' "$b" "PA=$G" "PA=$O" "$v"
done
echo "--- cells=$n  golden-PA-cells=$pa_g  ours-PA-cells=$pa_o  SAME=$agree DIFF=$disagree FAILED=$failed"
[ "$n" -gt 0 ] || { echo "FATAL: the grid reached NO cells"; exit 4; }
