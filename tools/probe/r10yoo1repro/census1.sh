#!/usr/bin/env bash
# r10yoo1 CENSUS-PREDICT -- an explicit UPPER BOUND on GATE 5's movers, computed
# from SOURCES before the byte verifier runs.
#
# § caTernOperandRead1 can only change a database that contains, in one module:
#   (a) a CONTINUOUS ASSIGN whose RHS is a TERNARY, and
#   (b) a parameter/localparam whose typespec carries a [w-1:0] range -- which
#       means a SIZED-LITERAL initialiser, a packed RANGE, or a written vector
#       type.
# Both are necessary; neither is sufficient (the ternary must not already fold,
# the parameter must actually sit in the condition or in a both-constant branch
# pair, and it must not be overridden).  So this is an UPPER BOUND and is
# labelled one -- a prediction that cannot be exceeded is the only kind worth
# recording.
#
# It deliberately does NOT try to decide foldability: that is an elaboration
# fact, and a grep that pretends to know it would produce a number that looks
# exact and is wrong.
set -u
U2R=${U2R:-$HOME/git-repos/uhdm2rtlil/test}
SLR=${SLR:-$HOME/git-repos/Surelog}
GREP=${GREP:-grep}

count_dirs() {           # <root> <label>
    local root=$1 label=$2 tot=0 hit=0 d
    while IFS= read -r d; do
        tot=$((tot + 1))
        # (a) a cont-assign with a ternary; (b) a ranged/sized param.  Both must
        # appear somewhere under the same test dir.
        if $GREP -rlE '^[[:space:]]*assign[^;]*\?' "$d" \
                --include='*.v' --include='*.sv' --include='*.vh' \
                --include='*.svh' -s > /dev/null 2>&1 &&
           $GREP -rlE "(parameter|localparam)([[:space:]]|.)*(\[|[0-9]+')" "$d" \
                --include='*.v' --include='*.sv' --include='*.vh' \
                --include='*.svh' -s > /dev/null 2>&1; then
            hit=$((hit + 1))
        fi
    done < <(find "$root" -mindepth 1 -maxdepth 1 -type d | sort)
    printf '%-12s %4d of %4d test dirs carry BOTH (a) and (b)\n' "$label" "$hit" "$tot"
}

echo "r10yoo1 CENSUS-PREDICT -- UPPER BOUND on movers (not a point estimate)"
count_dirs "$U2R" uhdm2rtlil
for r in "$SLR/tests" "$SLR/third_party/tests"; do
    [ -d "$r" ] && count_dirs "$r" "$(basename "$(dirname "$r")")/$(basename "$r")"
done
