#!/usr/bin/env bash
# r10svs11 CARRIER CENSUS — an UPPER BOUND, and it says so.
#
#   usage: ./census.sh            # both corpora
#
# WHAT IT PREDICTS.  § udpShapedConnNoIfaceNet11 can only move a database that
# contains BOTH (a) an `interface` declaration and (b) at least one
# instantiation whose connection list is ORDERED.  Neither condition is
# sufficient, so this is a NECESSARY-CONDITION filter, i.e. an UPPER BOUND on
# the mover set — never a prediction of it.  The byte verifier is the authority.
#
# WHY IT IS NOT SHARPER.  The predicate that actually decides a cell is
# `udpShapedInstantiation` (see src/EmitHelpers.h): ≥2 ordered terminals, every
# terminal non-empty, the FIRST terminal a `net_lvalue`, and any `#()` override
# still readable as `delay2`.  Deciding that needs slang's parse tree, which is
# exactly what the emitter has and a shell script does not.  r10svs10's census
# over-counted because it omitted one clause of its law; this one omits FOUR and
# is reported as the crude filter it is, not dressed up as a prediction.
#
# TRAPS ENCODED:
#   * `interface` also appears in `virtual interface`, `interface class` and in
#     comments, so the (a) test is deliberately loose and the count is an upper
#     bound in that direction too.
#   * the (b) test counts an instantiation-shaped line with a comma inside its
#     parens and NO leading `.` on the first argument.  `always @(a, b)`,
#     `function f(a, b)` and task calls all match it.  Loose ON PURPOSE: a
#     filter that misses a carrier is worse than one that over-reports.
set -u
ROOTS="${1:-$HOME/git-repos/Surelog/third_party/tests $HOME/git-repos/uhdm2rtlil/test}"
for root in $ROOTS; do
    [ -d "$root" ] || { echo "SKIP (absent): $root"; continue; }
    echo "==== corpus root: $root"
    tot=0; hit=0
    for d in "$root"/*/; do
        [ -d "$d" ] || continue
        tot=$((tot + 1))
        # (a) an interface declaration anywhere in the test
        grep -rlqE '^[[:space:]]*interface[[:space:]]+[A-Za-z_]' "$d" \
            --include='*.sv' --include='*.svh' --include='*.v' 2>/dev/null || continue
        # (b) an ordered (positional) connection list with >= 2 terminals
        n=$(grep -rhcE '^[[:space:]]*[A-Za-z_][A-Za-z_0-9]*([[:space:]]*#\([^)]*\))?[[:space:]]+[A-Za-z_][A-Za-z_0-9]*[[:space:]]*\([[:space:]]*[A-Za-z_][^.,()]*,' \
              "$d" --include='*.sv' --include='*.svh' --include='*.v' 2>/dev/null \
              | awk '{s+=$1} END {print s+0}')
        [ "${n:-0}" -gt 0 ] || continue
        hit=$((hit + 1))
        printf 'UPPER-BOUND CARRIER  %-44s ordered-list sites~%s\n' "$(basename "$d")" "$n"
    done
    echo "---- $root: $hit of $tot test dirs pass BOTH necessary conditions (UPPER BOUND)"
done
