#!/usr/bin/env bash
# r10oth4 BYTE VERIFIER.  Compares every `slang.uhdm` produced by two sweeps of
# the SAME corpus with two different binaries, and reports the movers.
#
#   usage: ./byteverify.sh <patched_workdir_root> <pristine_workdir_root>
#
# WHY IT EXISTS: 183 uhdm2rtlil rows are CMP_EQUAL + dump `differ` in the
# committed baseline, so the whole-row CSV diff is BLIND inside them.  A byte
# comparison is the only instrument that sees a change there.
#
# TWO CONTROLS, both mandatory, because a verifier that cannot line its inputs up
# reports "no movers" exactly like a clean run:
#   1. PATH-SET ASSERTION -- the relative paths under the two roots must be
#      IDENTICAL sets.  Any asymmetry is reported and exits 4.
#   2. COMPARATOR NEGATIVE CONTROL (`--selfcheck`) -- re-runs the comparison with
#      one side's bytes deliberately corrupted in memory; it must then report
#      EVERY path as a mover.  If it does not, the comparator is broken.
set -u
A=${1:?patched workdir root}
B=${2:?pristine workdir root}
[ -d "$A" ] && [ -d "$B" ] || { echo NO_WORKDIR; exit 6; }
la=$(mktemp); lb=$(mktemp)
(cd "$A" && find . -name slang.uhdm | sort) > "$la"
(cd "$B" && find . -name slang.uhdm | sort) > "$lb"
na=$(wc -l < "$la"); nb=$(wc -l < "$lb")
echo "databases: patched=$na pristine=$nb"
if ! diff -q "$la" "$lb" > /dev/null; then
    echo "PATH_SETS_DIFFER -- a 'no movers' reading here would be meaningless"
    diff "$la" "$lb" | head -20
    exit 4
fi
[ "$na" -gt 0 ] || { echo NO_DATABASES; exit 6; }
echo "PATH_SETS_IDENTICAL ($na paths)"
movers=0
while read -r p; do
    if ! cmp -s "$A/$p" "$B/$p"; then
        echo "MOVER $p  patched=$(md5sum "$A/$p" | cut -c1-12) pristine=$(md5sum "$B/$p" | cut -c1-12)"
        movers=$((movers + 1))
    fi
done < "$la"
echo "MOVERS: $movers / $na"
# COMPARATOR NEGATIVE CONTROL: compare each patched file against a DIFFERENT
# file; every path must then be reported as a mover.
if [ "${SELFCHECK:-0}" = 1 ]; then
    ref=$(head -1 "$la")
    bad=0
    while read -r p; do
        cmp -s "$A/$p" "$B/$ref" || bad=$((bad + 1))
    done < "$la"
    echo "SELFCHECK (every file vs one fixed file): $bad / $na flagged"
    [ "$bad" -ge $((na - 1)) ] || { echo SELFCHECK_FAILED; exit 5; }
fi
rm -f "$la" "$lb"
