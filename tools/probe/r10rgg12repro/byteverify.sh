#!/usr/bin/env bash
# r10rgg12 (carried from r10rgg9)/byteverify.sh — the MOVER gate: which databases changed BYTE-WISE
# between the base and the patched binary, over a whole verify_golden workdir
# pair.  A pass must NAME and ATTRIBUTE every mover, and must have PREDICTED the
# set from the pristine databases BEFORE running this.
#
#   usage: SELFCHECK=1 byteverify.sh <base-workdir> <pat-workdir> [outfile]
#
# GUARDS:
#   * a test present in one workdir and not the other is ONLY-IN-<side> and is
#     COUNTED; a driver that compares nothing must never read as agreement.
#   * SELFCHECK=1 runs the same comparison of the BASE workdir against ITSELF
#     first: it MUST report zero movers.  A comparator that cannot see a
#     difference reports zero for the real run too.
set -u
A=${1:?base workdir}
B=${2:?pat workdir}
OUT=${3:-/dev/stdout}
cmpdirs() {
  local x=$1 y=$2
  local mv=0 same=0 onlyx=0 onlyy=0
  for f in "$x"/*/*/slang.uhdm; do
    [ -f "$f" ] || continue
    rel=${f#$x/}
    g=$y/$rel
    if [ ! -f "$g" ]; then echo "ONLY-IN-A $rel"; onlyx=$((onlyx+1)); continue; fi
    if cmp -s "$f" "$g"; then same=$((same+1)); else echo "MOVER $rel"; mv=$((mv+1)); fi
  done
  for f in "$y"/*/*/slang.uhdm; do
    [ -f "$f" ] || continue
    rel=${f#$y/}
    [ -f "$x/$rel" ] || { echo "ONLY-IN-B $rel"; onlyy=$((onlyy+1)); }
  done
  echo "-- identical=$same MOVERS=$mv only-in-A=$onlyx only-in-B=$onlyy"
}
{
if [ "${SELFCHECK:-0}" = "1" ]; then
  echo "==== SELFCHECK: base vs base (MUST be 0 movers)"
  cmpdirs "$A" "$A"
fi
echo "==== base vs patched"
cmpdirs "$A" "$B"
} > "$OUT" 2>&1
