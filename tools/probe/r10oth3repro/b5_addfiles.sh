#!/usr/bin/env bash
# r10oth3 DIRECTION B (YosysOldOr) UPWARD bisector.
#
# r10oth2 proved the DOWNWARD search is exhausted: each line-113 file alone is
# PASS_CMP, and the two of them together with the union of their dependencies is
# PASS_CMP too.  So the trigger must be ADDED, and this driver takes an
# arbitrary file list, compiles it with BOTH tools exactly the way the harness's
# `testflags` row does (`-parse +incdir+.+rtl rtl/<file> ...`, run from the test
# directory so file identity and spans match the real run), and reports the
# AUTHORITATIVE fold classification of the five `range 113:8-113:16` objects.
#
#   usage: SLANG_UHDM=/path/to/slang-uhdm ./b5_addfiles.sh <tag> <file> [<file>...]
#          SLANG_UHDM=... ./b5_addfiles.sh <tag> @<listfile>
#
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
# SLANG_UHDM has NO DEFAULT: scripts/verify_golden.py:52 and
# tests/check_goldens.sh:5 both fall back to the MAIN-TREE binary and a
# wrong-binary measurement is indistinguishable from a real result.
set -u
: "${SLANG_UHDM:?set SLANG_UHDM to the build under test}"
HERE=$(cd "$(dirname "$0")" && pwd)
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
SRCDIR=${OR1200_DIR:-$HOME/git-repos/Surelog/third_party/tests/YosysOldTests/or1200}
TAG=$1; shift
if [ "${1#@}" != "$1" ]; then FILES=$(cat "${1#@}"); else FILES="$*"; fi
NF=$(echo $FILES | wc -w)
D=/tmp/r10oth3_b5_$TAG
rm -rf "$D"; mkdir -p "$D" || exit 9
ARGS=""
for f in $FILES; do ARGS="$ARGS rtl/$f"; done
cd "$SRCDIR" || exit 9
"$SURELOG" -parse -nocache +incdir+.+rtl $ARGS -mt 0 -mp 0 -o "$D/sl" \
    > "$D/surelog.log" 2>&1
GOLD=$(find "$D/sl" -name '*.uhdm' | head -1)
[ -n "$GOLD" ] && [ -f "$GOLD" ] || { echo "$TAG nf=$NF SURELOG_FAIL"; tail -4 "$D/surelog.log"; exit 5; }
# --ignore-unknown-modules is what makes an UPWARD bisection possible at all:
# Surelog happily writes a database for a file set with dangling instances, but
# slang rejects it ("unknown module 'or1200_ic_tag'"), so without this flag every
# subset that is not dependency-CLOSED is NO_OUTPUT and the only testable sets
# are the 22-file closure and the whole design.  The flag is used on EVERY row
# including the full-design POSITIVE CONTROL, and the control still reproduces
# golden 2 UNFOLDED / 3 FOLDED vs ours 1 / 4, so it does not blind the probe.
"$SLANG_UHDM" +incdir+.+rtl $ARGS --single-unit --ignore-unknown-modules \
    -o "$D/slang.uhdm" > "$D/slang.log" 2>&1
# uhdm-cmp EXITS 0 ON A MISSING INPUT FILE ("File does not exist!"), so without
# this guard the cmp below prints PASS on a run that produced nothing.
[ -f "$D/slang.uhdm" ] || { echo "$TAG nf=$NF NO_OUTPUT"; tail -4 "$D/slang.log"; exit 6; }
"$DUMP" "$GOLD" 2>/dev/null | sed '1d' > "$D/g.dump"
"$DUMP" "$D/slang.uhdm" 2>/dev/null | sed '1d' > "$D/o.dump"
# --expect 1 is the POSITIVE CONTROL: a compile that contains no line-113 range
# at all must report PROBE_BLIND, not "0 unfolded / 0 folded".
# NOTE the shell trap this avoids: `X=$(python3 ... | sed -n 2p) || X=BLIND`
# tests SED's exit status, not python's, so the --expect guard would NEVER fire
# and a blind probe would print a reassuring "0 UNFOLDED / 0 FOLDED".  Run the
# instrument, keep its status, and only then slice the output.
if python3 "$HERE/loc113b.py" --expect 1 "$D/g.dump" > "$D/g.loc" 2>/dev/null
then GS=$(sed -n 2p "$D/g.loc"); else GS=" PROBE_BLIND(golden) - no line-113 range in this file set"; fi
if python3 "$HERE/loc113b.py" --expect 1 "$D/o.dump" > "$D/o.loc" 2>/dev/null
then OS=$(sed -n 2p "$D/o.loc"); else OS=" PROBE_BLIND(ours) - no line-113 range in this file set"; fi
if "$CMP" "$GOLD" "$D/slang.uhdm" > "$D/cmp.log" 2>&1; then V=PASS_CMP; else V=CMP_FAIL; fi
echo "$TAG nf=$NF $V heads=$(grep -c '^LHS:' "$D/cmp.log")"
echo "   golden(LHS):$GS"
echo "   ours  (RHS):$OS"
echo "   WD=$D"
