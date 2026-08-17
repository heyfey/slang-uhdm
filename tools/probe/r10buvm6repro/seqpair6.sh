#!/usr/bin/env bash
# r10buvm6 — THE DECISIVE CONTROL FOR THE TWO REORDER RESIDUES.
#
# The sweep pair (patched tree vs pristine tree) shows, on default/Scoreboard and
# testflags/SeqDriver, a residue stripdollar.py cannot attribute to a `$`
# constant.  Two facts are already measured about it:
#   * it is a PURE REORDER — after the `$` blocks are stripped, the two dumps are
#     IDENTICAL AS LINE MULTISETS (`sort | cmp`): no object, field or value
#     differs, only the position of entries in one package-level list;
#   * default/Scoreboard reproduces it PRISTINE-vs-PRISTINE (detsweep6.sh), so
#     for that row the emitter's own run-to-run order is the cause, full stop.
#
# testflags/SeqDriver did NOT flip in that one pristine A/B trial, and a coin that
# did not land is not evidence.  This script settles it WITHOUT relying on a
# flake firing: it runs BOTH BINARIES SEQUENTIALLY, one after the other, in the
# test's own directory with the row's own argv (read out of the sweep workdir's
# cmds.txt, minus its `-o`), and compares the two dumps with the `$` blocks
# stripped.  If the sequential pair has ZERO residue, the reorder is not a
# function of the binary difference — it is scheduling in the sweep — and the
# whole of this pass's effect on that row is `$` constants.
#
#   usage: seqpair6.sh <patched-bin> <pristine-bin> <testdir> <outdir> <argv...>
#
# GUARDS: uhdm-dump's first line is the database path and the two paths differ,
# so `sed 1d` on both sides; a missing database on either side is FATAL, never
# "no residue"; the stripped remainder is compared BOTH in order and as a sorted
# multiset, so a reorder and a content change can never be confused.
set -u
P=${1:?patched bin}; R=${2:?pristine bin}; TD=${3:?test dir}; OUT=${4:?outdir}
shift 4
HERE=$(cd "$(dirname "$0")" && pwd)
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
mkdir -p "$OUT" || exit 9
cd "$TD" || exit 3
for side in pat pris; do
  BIN=$P; [ "$side" = pris ] && BIN=$R
  "$BIN" "$@" -o "$OUT/$side.uhdm" > "$OUT/$side.log" 2>&1
  [ -f "$OUT/$side.uhdm" ] || { echo "FATAL: $side produced no database"; exit 4; }
  "$DUMP" "$OUT/$side.uhdm" 2>/dev/null | sed 1d > "$OUT/$side.dump"
  python3 "$HERE/stripdollar.py" "$OUT/$side.dump" > "$OUT/$side.strip"
done
d=$(diff -u "$OUT/pris.dump" "$OUT/pat.dump" | grep -E '^[-+]' | grep -vcE '^(---|\+\+\+) ' || true)
r=$(diff -u "$OUT/pris.strip" "$OUT/pat.strip" | grep -E '^[-+]' | grep -vcE '^(---|\+\+\+) ' || true)
LC_ALL=C sort "$OUT/pris.strip" > "$OUT/pris.sorted"
LC_ALL=C sort "$OUT/pat.strip"  > "$OUT/pat.sorted"
m=OK; cmp -s "$OUT/pris.sorted" "$OUT/pat.sorted" || m=MULTISETS-DIFFER
echo "SEQUENTIAL PAIR: rawdiff=$d  residue-after-stripping-\$=$r  multiset=$m"
[ "$r" -eq 0 ] && [ "$m" = OK ] && echo "PASS: sequentially, the ENTIRE difference between the two binaries is \$ constants" \
                                || { echo "FAIL: a sequential residue survives"; exit 1; }
