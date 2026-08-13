#!/usr/bin/env bash
# r10svs13 — GATE 1's BASE MARKER, BEHAVIOURAL AND TWO-DIRECTIONAL.
#
#   usage: ./basemark.sh <slang-binary>
#
# WHY IT IS NOT A SYMBOL GREP.  This pass adds no new symbol: the law name lives
# only in comments, so `strings <binary> | grep -c progPortIfaceArrayUnowned13`
# is 0 on the SHIPPED binary too and quoting it would be a guard that does not
# guard.  The gate it installs reads `m->UhdmType()`, a pre-existing accessor.
#
# So the marker is BEHAVIOUR, stated in BOTH directions so a binary cannot pass
# it by accident:
#   REMOVED  arm a1, cell p1 (a PROGRAM instance)  -> `|vpiInterfaceArray:` label
#              pristine = 1     shipped = 0
#   ADDED    the same wrapper's own listing in uhdm-dump's `weaklyReferenced`
#            tail, at INDENT 0 (it has no owner any more)
#              pristine = 0     shipped = 1
#   CONTROL  arm a1, cell m1 (a MODULE instance) -> `|vpiInterfaceArray:` label
#              BOTH binaries = 1
# Run this on EVERY binary whose numbers this pass quotes.
set -u
BIN=${1:?slang binary}
HERE=$(cd "$(dirname "$0")" && pwd)
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
[ -x "$BIN" ] || { echo "FATAL: not executable: $BIN"; exit 3; }
D=$(mktemp -d /tmp/r10svs13_mark_XXXX)
cp "$HERE/a1_ifarrport.sv" "$D/" || exit 9
cd "$D" || exit 9
echo "BIN=$BIN md5=$(md5sum "$BIN" | cut -d' ' -f1)"
"$BIN" a1_ifarrport.sv -o slang.uhdm >slang.log 2>&1
[ -f slang.uhdm ] || { echo NO_OUTPUT; tail -5 slang.log; exit 6; }
"$DUMP" slang.uhdm 2>/dev/null | sed '1d' > o.dump
[ -s o.dump ] || { echo NO_DUMP; exit 7; }
python3 "$HERE/iaread.py" o.dump o.dump --obj '(work@top.p1)' --obj '(work@top.m1)' \
  | grep -E "OBJ|RHS ours"
echo "TAIL (indent-0 own listing of the unowned wrapper):"
echo "  \\_interface_array: (a) at indent 0 = $(grep -c '^\\_interface_array: (a),' o.dump)"
rm -rf "$D"
