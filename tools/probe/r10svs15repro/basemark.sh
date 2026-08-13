#!/usr/bin/env bash
# r10svs15 — GATE 1's BASE MARKER, BEHAVIOURAL AND TWO-DIRECTIONAL.
#
#   usage: ./basemark.sh <slang-binary>
#
# WHY IT IS NOT ONLY A SYMBOL GREP.  This pass DOES add a symbol
# (`drainCbElabRefs15`), and it is asserted below — but a symbol proves the
# object file was linked, not that the law FIRES.  So the marker is BEHAVIOUR
# first, stated in BOTH directions on the SAME observable, with two controls that
# must NOT move, so that neither binary can pass it by accident:
#
#   MOVER      arm a1 cell c1: `work@top.c1a[1].cb.clock`'s vpiActual
#                pristine = (unbound)    shipped = bit_var work@top.c1a[0].clock
#   CONTROL A  the FIRST element's own ref, `work@top.c1a[0].cb.clock`
#                BOTH binaries = (unbound)      <- the asymmetry IS the law
#   CONTROL B  the SCALAR twin, `work@top.c8s.cb.clock`
#                BOTH binaries = (unbound)
#   CONTROL C  the DEF view's ref, `work@c1_if.cb.clock`
#                BOTH binaries = bit_var work@top.c1a[0].clock  (already correct)
#   SYMBOL     `drainCbElabRefs15` present in the binary's strings
#                pristine = 0        shipped = 1
#
# Run this on EVERY binary whose numbers this pass quotes.
#
# TRAPS ENCODED: uhdm-dump's FIRST LINE is the database path -> `sed 1d`, as
# everywhere else here; a missing binary/dump is a hard exit, never an empty
# table that reads as "no change".
set -u
BIN=${1:?slang binary}
HERE=$(cd "$(dirname "$0")" && pwd)
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
[ -x "$BIN" ] || { echo "FATAL: not executable: $BIN"; exit 3; }
[ -x "$DUMP" ] || { echo "FATAL: no uhdm-dump: $DUMP"; exit 3; }
D=$(mktemp -d /tmp/r10svs15_mark_XXXX)
cp "$HERE/a1_cbarr.sv" "$D/" || exit 9
cd "$D" || exit 9
echo "BIN=$BIN md5=$(md5sum "$BIN" | cut -d' ' -f1)"
echo "SYMBOL drainCbElabRefs15 = $(strings "$BIN" | grep -c drainCbElabRefs15)"
"$BIN" a1_cbarr.sv -o slang.uhdm >slang.log 2>&1
[ -f slang.uhdm ] || { echo NO_OUTPUT; tail -5 slang.log; exit 6; }
"$DUMP" slang.uhdm 2>/dev/null | sed '1d' > o.dump
[ -s o.dump ] || { echo NO_DUMP; exit 7; }
# The census reads OURS from the second column, so the same dump is passed twice
# and only the OURS field is quoted.  The OURS field is read by FIXED COLUMN
# (cbcensus.sh's format is `%-46s %-26s %-34s %-34s %s`, so OURS is cols
# 110..143) and NOT by awk field number: `(unbound)` is ONE whitespace-separated
# token and `bit_var work@...` is TWO, so a field-number read prints the verdict
# column for one binary and the value for the other -- which is exactly what the
# first cut of this script did, and it made the pristine run look like a mover.
"$HERE/cbcensus.sh" o.dump o.dump > cen.txt || exit 8
q() {  # <label> <exact ref fullname>
    local v
    v=$(grep -F -- "$2 " cen.txt | head -1 | cut -c110-143 | sed 's/ *$//')
    [ -n "$v" ] || { echo "  $1 $2 = ABSENT-FROM-CENSUS"; return; }
    printf '  %-10s %-34s = %s\n' "$1" "$2" "$v"
}
q MOVER     "work@top.c1a[1].cb.clock"
q "CONTROL A" "work@top.c1a[0].cb.clock"
q "CONTROL B" "work@top.c8s.cb.clock"
q "CONTROL C" "work@c1_if.cb.clock"
rm -rf "$D"
