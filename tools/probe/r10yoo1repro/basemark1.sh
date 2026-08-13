#!/usr/bin/env bash
# r10yoo1 -- GATE 1's BASE MARKER, BEHAVIOURAL AND TWO-DIRECTIONAL.
#
#   usage: ./basemark1.sh <slang-binary>
#
# THERE IS DELIBERATELY NO SYMBOL ROW.  § caTernOperandRead1 adds no new
# function -- it widens the harvest inside the existing `paramCaFoldRead`, and
# its name lives only in a comment, which no binary contains.  A `strings | grep`
# row here would therefore report 0 for BOTH binaries and read as "the patch is
# missing"; inventing a symbol just to have a row to print would be worse.  So
# the marker is behaviour ONLY, stated in BOTH directions on one observable, with
# FOUR controls that must NOT move, so neither binary can pass it by accident.
#
#   MOVER      a5 y1 `work@y1_tern_branches` A1 -- both ternary branches are
#              params, the condition reads nets
#                pristine = int_typespec LOCATED [INT:..]
#                shipped  = logic_typespec SPANLESS [UINT:..]
#   CONTROL A  a5 y4 D1 -- ONE branch a param, the other a net.  BOTH binaries
#              LOCATED.  This is the `&&` in "BOTH branches fold" and it is the
#              only thing separating the law from "any param in a branch".
#   CONTROL B  a5 y2 B1 -- `assign o = nb & B1`, not a ternary.  BOTH LOCATED.
#   CONTROL C  a5 y8 H1 -- never read at all.  BOTH LOCATED.
#   CONTROL D  a7 k3 R1 -- an OVERRIDDEN param in the mover's exact read shape.
#              BOTH LOCATED, which is the caller's !isOverriddenParam gate.
#
# Run this on EVERY binary whose numbers this pass quotes.
#
# TRAPS ENCODED:
#  * the census probe is fed the SAME database twice and only its OURS line is
#    read, so this script needs no golden and cannot accidentally quote one.
#  * the OURS value is taken by stripping a FIXED LITERAL PREFIX, never by awk
#    field number: `int_typespec@12:4-12:9 [INT:30:INT:0]` is two
#    whitespace-separated tokens and `logic_typespec@SPANLESS [UINT:30:UINT:0]`
#    is two as well, but a `norange` value is ONE -- a field-number read prints a
#    different column per binary, which is exactly the bug that made r10svs15's
#    first marker call its pristine run a mover.
#  * a missing binary/database/probe is a HARD EXIT, never an empty table that
#    reads as "no change".
set -u
BIN=${1:?slang binary}
HERE=$(cd "$(dirname "$0")" && pwd)
PA=${PA:-/tmp/r10yoo1pa}
[ -x "$BIN" ] || { echo "FATAL: not executable: $BIN"; exit 3; }
[ -x "$PA" ]  || { echo "FATAL: no census probe $PA (build r10yoo1pa.cpp)"; exit 3; }
D=$(mktemp -d /tmp/r10yoo1_mark_XXXX)
cp "$HERE/a5_readshape.v" "$HERE/a7_instantiated.v" "$D/" || exit 9
cd "$D" || exit 9
echo "BIN=$BIN md5=$(md5sum "$BIN" | cut -d' ' -f1)"
for f in a5_readshape a7_instantiated; do
    "$BIN" $f.v --single-unit -o $f.uhdm > $f.log 2>&1
    [ -f $f.uhdm ] || { echo "FATAL: no database for $f"; tail -5 $f.log; exit 6; }
done
q() {  # <label> <db> <exact census key>
    local v
    v=$("$PA" "$2.uhdm" "$2.uhdm" "$3" 2>/dev/null \
        | grep -F -A2 -- "$3" | grep '^    OURS   ' | head -1 \
        | sed 's/^    OURS   //')
    [ -n "$v" ] || { printf '  %-10s %-42s = ABSENT-FROM-CENSUS\n' "$1" "$3"; return; }
    printf '  %-10s %-42s = %s\n' "$1" "$3" "$v"
}
q MOVER       a5_readshape    "TOP|work@y1_tern_branches|A1"
q "CONTROL A" a5_readshape    "TOP|work@y4_one_branch|D1"
q "CONTROL B" a5_readshape    "TOP|work@y2_and_operand|B1"
q "CONTROL C" a5_readshape    "TOP|work@y8_neverread|H1"
q "CONTROL D" a7_instantiated "TOP|work@k3_parent.u3|R1"
cd /
rm -rf "$D"
