#!/usr/bin/env bash
# r10earl44 — run Earlgrey_0_1 in DEFAULT mode with ONE binary and produce
# {slang.uhdm, o.dump, cmp.log}. The GOLDEN side is taken from the immutable
# golden cache (scripts/verify_golden.py's key), never re-run.
#
#   usage: SLANG_UHDM=/abs/path/build/slang-uhdm ./earl44.sh <outdir> [--nodump]
#
# Ops traps encoded here (each one has burned this campaign):
#   * SLANG_UHDM has NO DEFAULT and its md5 is PRINTED on every run — a
#     stale-binary reading is the single most expensive mistake available.
#   * uhdm-dump's FIRST LINE IS THE DATABASE PATH and always differs -> sed 1d.
#   * uhdm-cmp EXITS 0 WHEN AN INPUT IS MISSING -> explicit -f guards.
#   * slang must run with cwd = the test dir (the .scr filelist is relative).
#   * cmp LINE COUNT is HEAD DEPTH, never a distance.
set -u
TESTDIR=/home/heyfey/git-repos/Surelog/third_party/tests/Earlgrey_0_1/sim-icarus
GOLDEN=${GOLDEN_UHDM:-/home/heyfey/.cache/slang-uhdm-goldens/00d4794526e44dc553f3/golden.uhdm}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
D=${1:?outdir}
NODUMP=${2:-}
: "${SLANG_UHDM:?set SLANG_UHDM to the build under test}"
[ -x "$SLANG_UHDM" ] || { echo "FATAL: no such binary $SLANG_UHDM"; exit 9; }
for t in "$DUMP" "$CMP"; do [ -x "$t" ] || { echo "FATAL: no such tool $t"; exit 9; }; done
[ -f "$GOLDEN" ] || { echo "FATAL: no golden $GOLDEN"; exit 9; }
echo "BINARY $SLANG_UHDM md5=$(md5sum "$SLANG_UHDM" | cut -d' ' -f1)"
mkdir -p "$D" || exit 9
D=$(cd "$D" && pwd)
rm -f "$D/slang.uhdm"
( cd "$TESTDIR" && "$SLANG_UHDM" +define+SYNTHESIS -f lowrisc_systems_top_earlgrey_0.1.scr \
    --single-unit -o "$D/slang.uhdm" ) >"$D/slang.log" 2>&1
[ -f "$D/slang.uhdm" ] || { echo SLANG_REJECT; tail -5 "$D/slang.log"; exit 6; }
"$CMP" "$GOLDEN" "$D/slang.uhdm" >"$D/cmp.log" 2>&1 && echo PASS_CMP || echo CMP_NOTEQUAL
echo "cmp heads=$(grep -c '^LHS:' "$D/cmp.log") lines=$(wc -l < "$D/cmp.log") (HEAD DEPTH ONLY)"
if [ "$NODUMP" != "--nodump" ]; then
  "$DUMP" "$D/slang.uhdm" 2>/dev/null | sed '1d' > "$D/o.dump"
  [ -s "$D/o.dump" ] || { echo NO_OURS_DUMP; exit 7; }
  echo "o.dump lines=$(wc -l < "$D/o.dump")"
fi
echo "WD=$D"
