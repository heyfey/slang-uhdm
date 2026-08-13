#!/usr/bin/env bash
# r10svs14 — GATE 1's BASE MARKER, BEHAVIOURAL AND TWO-DIRECTIONAL.
#
#   usage: ./basemark.sh <slang-binary>
#
# WHY IT IS NOT A SYMBOL GREP.  This pass adds no new symbol: the law name lives
# only in a comment, so `strings <binary> | grep -c ifaceDupVarsAreHomeVars14` is
# 0 on the SHIPPED binary too and quoting it would be a guard that does not guard.
# The code it installs calls `home->Variables()`, a pre-existing accessor.
#
# So the marker is BEHAVIOUR, and it is stated in BOTH directions on the SAME
# observable so that a binary cannot pass it by accident.  Arm b1 cell c1 is
# `interface if_bit(input bit clock)` with two logic body vars, handed WHOLE to a
# sibling module's modport port — the SVSwitch witness shape:
#
#   COUNT       c1's col-0 DUP `vpiVariables` entries
#                 pristine = 2        shipped = 3
#   FIRST SLOT  the FIRST of those entries
#                 pristine = logic_var d          shipped = bit_var clock
#   CONTROL A   c2 (`input wire clk`, InterfaceModPort's shape) DUP entries
#                 BOTH binaries = 2, first = logic_var d
#   CONTROL B   c1's HOME view entries (already correct before this pass)
#                 BOTH binaries = 3, first = bit_var clock
#
# Run this on EVERY binary whose numbers this pass quotes.
set -u
BIN=${1:?slang binary}
HERE=$(cd "$(dirname "$0")" && pwd)
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
[ -x "$BIN" ] || { echo "FATAL: not executable: $BIN"; exit 3; }
[ -x "$DUMP" ] || { echo "FATAL: no uhdm-dump: $DUMP"; exit 3; }
D=$(mktemp -d /tmp/r10svs14_mark_XXXX)
cp "$HERE/b1_hdrport.sv" "$D/" || exit 9
cd "$D" || exit 9
echo "BIN=$BIN md5=$(md5sum "$BIN" | cut -d' ' -f1)"
"$BIN" b1_hdrport.sv -o slang.uhdm >slang.log 2>&1
[ -f slang.uhdm ] || { echo NO_OUTPUT; tail -5 slang.log; exit 6; }
# uhdm-dump's FIRST LINE is the database path -> sed 1d, as everywhere else here.
"$DUMP" slang.uhdm 2>/dev/null | sed '1d' > o.dump
[ -s o.dump ] || { echo NO_DUMP; exit 7; }
# dupread.py needs two dumps; the marker reads only the OURS column, so the same
# dump is passed twice and only the `OURS` lines are quoted.
python3 "$HERE/dupread.py" o.dump o.dump --all |
  awk '/^OBJ (DUP|HOME) +work@if_(bit|wire) +work@top\.c[12] /{k=$2" "$4; next}
       k && /^ +OURS/ {sub(/^ +OURS +vars /,""); print "  "k"  "$0; k=""}'
rm -rf "$D"
