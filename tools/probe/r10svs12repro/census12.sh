#!/usr/bin/env bash
# r10svs12 CARRIER CENSUS — an UPPER BOUND, and it says so.
#
#   usage: ./census12.sh            # both corpora
#
# WHAT IT PREDICTS.  § arrayBcastPortPositionalNoFormal12 can only move a
# database that contains an INSTANCE ARRAY declaration — `Type name[range](…)`,
# module or interface — whose connection list is written POSITIONALLY.  Both
# conditions are NECESSARY; neither is sufficient, so this is an UPPER BOUND on
# the mover set and never a prediction of it.  The byte verifier (GATE 5) is the
# authority.
#
# WHY IT IS NOT SHARPER.  Four clauses of the producer decide whether an array
# instantiation reaches the broadcast-port loop AT ALL, and none of them is
# visible to a shell script:
#   * a MODULE array in the ELAB view returns early (`modElems`) — only the DEF
#     view carries broadcast ports, and only the DEF view of an array whose
#     `udpFormInstantiation` answer is NO gets a `module_array` at all
#     (arm d2 m3/m5: two positional terminals and no `#()` -> NO container, so a
#     positional two-terminal module array is a NON-carrier);
#   * `connectionExpr(*conn)` must be non-null (an empty terminal is skipped);
#   * an INTERFACE array (`ifaceArr`) skips every non-`NamedValue` actual
#     entirely (arm d3 k3/k5/k7);
#   * the array must actually be elaborated (unreferenced defs are not emitted).
# r10svs11's census over-counted by 41x for the same reason and said so; this one
# is reported as the crude filter it is.
#
# TRAPS ENCODED:
#   * the (a) test's `[` … `]` also matches a packed-vector NET declaration
#     (`logic [7:0] x;`) — those have no parenthesised connection list, so the
#     `(` requirement on the SAME line filters most of them; the count is still
#     an upper bound in that direction.
#   * the (b) test reads only the FIRST terminal, which is exactly what
#     `hasOrderedConns` reads (it returns true on any OrderedPortConnection, and
#     1800 forbids mixing), but it cannot see a continuation line, so a
#     multi-line connection list is counted as positional whenever its first
#     line has no leading `.`.  Loose ON PURPOSE: a filter that misses a carrier
#     is worse than one that over-reports.
set -u
ROOTS="${1:-$HOME/git-repos/Surelog/third_party/tests $HOME/git-repos/uhdm2rtlil/test}"
PAT='^[[:space:]]*[A-Za-z_][A-Za-z_0-9]*([[:space:]]*#\([^)]*\))?[[:space:]]+[A-Za-z_][A-Za-z_0-9]*[[:space:]]*\[[^]]*\][[:space:]]*\([[:space:]]*[A-Za-z_0-9'"'"'{(]'
for root in $ROOTS; do
    [ -d "$root" ] || { echo "SKIP (absent): $root"; continue; }
    echo "==== corpus root: $root"
    tot=0; hit=0
    for d in "$root"/*/; do
        [ -d "$d" ] || continue
        tot=$((tot + 1))
        n=$(grep -rhcE "$PAT" "$d" --include='*.sv' --include='*.svh' \
              --include='*.v' 2>/dev/null | awk '{s+=$1} END {print s+0}')
        [ "${n:-0}" -gt 0 ] || continue
        hit=$((hit + 1))
        printf 'UPPER-BOUND CARRIER  %-44s positional-array sites~%s\n' \
               "$(basename "$d")" "$n"
    done
    echo "---- $root: $hit of $tot test dirs pass BOTH necessary conditions (UPPER BOUND)"
done
