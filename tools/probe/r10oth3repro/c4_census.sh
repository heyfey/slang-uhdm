#!/usr/bin/env bash
# r10oth3 TARGET 1 blast-radius census.
#
# Arm c1/c3 established that golden(Surelog) OVERWRITES the RHS constant of a
# compound assignment (`x += 1`) with the RESULT of the operation while it
# EVALUATES a constant function, cumulatively across every evaluation.  Before
# any emitter rule can be written for that, the brief demands knowing HOW WIDE
# the shape is: if `+= <literal>` inside an elaboration-evaluated function is
# common, any law that changes those constants would move many currently
# CMP_EQUAL rows.
#
# This counts, over BOTH corpora's sources, files that contain a compound
# assignment with a LITERAL right-hand side inside a function/task body.  It is
# a TEXT census and it deliberately over-counts (it cannot tell an
# elaboration-evaluated function from a simulation-only one); the point is the
# ORDER OF MAGNITUDE of the blast radius, and an over-count is the safe
# direction for that question.
#
# POSITIVE CONTROL: the census asserts it can find Rggen's OWN witness
# (rggen_or_reducer.sv) and exits 3 if it cannot -- a census reporting zero is
# indistinguishable from one that can see nothing.
set -u
SL=${SURELOG_ROOT:-$HOME/git-repos/Surelog}
U2R=${UHDM2RTLIL_TESTS:-$HOME/git-repos/uhdm2rtlil/test}
PAT='[A-Za-z_][A-Za-z_0-9]*[ 	]*[-+*/&|^]=[ 	]*[0-9]'

echo "== files containing a compound assignment with a literal RHS"
for root in "$SL/tests" "$SL/third_party/tests" "$U2R"; do
    [ -d "$root" ] || { echo "  MISSING ROOT $root"; continue; }
    n=$(grep -rlE "$PAT" --include='*.v' --include='*.sv' --include='*.svh' \
            "$root" 2>/dev/null | wc -l)
    echo "  $root : $n files"
done

echo "== of those, the files that ALSO declare a function (the shape that can be"
echo "   evaluated at elaboration and therefore mutated)"
TMP=$(mktemp /tmp/r10oth3_census.XXXXXX)
for root in "$SL/tests" "$SL/third_party/tests" "$U2R"; do
    [ -d "$root" ] || continue
    grep -rlE "$PAT" --include='*.v' --include='*.sv' --include='*.svh' \
        "$root" 2>/dev/null
done | sort -u > "$TMP"
tot=$(wc -l < "$TMP")
fn=0
while read -r f; do
    grep -qE '^[ 	]*function' "$f" && fn=$((fn + 1))
done < "$TMP"
echo "  $fn of $tot files with a compound-literal assignment also declare a function"

echo "== POSITIVE CONTROL: Rggen's own witness must be in the list"
if grep -q 'rggen_or_reducer.sv' "$TMP"; then
    echo "  FOUND rggen_or_reducer.sv -- the census can see its probe"
else
    echo "  PROBE NOT FOUND -- census is blind, every number above is worthless"
    rm -f "$TMP"
    exit 3
fi
echo "== the witness line"
grep -n 'list_index' "$SL/third_party/tests/rggen/rggen-sv-rtl/rggen_or_reducer.sv" | sed -n 5p
rm -f "$TMP"
