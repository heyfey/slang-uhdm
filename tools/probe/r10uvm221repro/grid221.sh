#!/bin/bash
# r10uvm221repro/grid221.sh — THE GOLDEN GRID for § uninstIfaceEnumConstNoActual221.
#
#   usage: grid221.sh <outdir> [<slang-uhdm binary>]
#
# For every arm directory under grid221/ it builds
#   * golden (Surelog) in the PARSE view (-parse, MiniAmiq's own view) and in
#     the ELABORATED view (-parse -elabuhdm), and
#   * ours, when a binary is given,
# and dumps each database.  EVERY arm records its rc: a compile that FAILS
# teaches error recovery, not golden (uvm215's lesson), so a non-zero rc is
# printed and the arm is counted as FAILED, never as agreement.
#
# The file list is read on fd 3 and every child gets </dev/null so no child can
# swallow it (sd8-12's trap); scratch is keyed on the arm's RELATIVE path;
# PROCESSED is asserted against LISTED at the end.
set -u
OUT=${1:?outdir}
OURS=${2:-}
HERE=$(cd "$(dirname "$0")" && pwd)
SL=$HOME/git-repos/Surelog/build/bin/surelog      # the path scripts/verify_golden.py names
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
[ -x "$SL" ] || { echo "FATAL: no surelog at $SL"; exit 3; }
[ -x "$DUMP" ] || { echo "FATAL: no uhdm-dump at $DUMP"; exit 3; }
[ -z "$OURS" ] || [ -x "$OURS" ] || { echo "FATAL: no binary at $OURS"; exit 3; }
mkdir -p "$OUT" || exit 1

LISTED=0; PROCESSED=0; FAILED=0
find "$HERE/grid221" -mindepth 1 -maxdepth 1 -type d | sort > "$OUT/.arms.txt"
LISTED=$(wc -l < "$OUT/.arms.txt")
exec 3< "$OUT/.arms.txt"
while read -r ARM <&3; do
  rel=$(basename "$ARM")
  for view in parse elab; do
    W=$OUT/$rel.$view
    rm -rf "$W"; mkdir -p "$W"
    if [ "$view" = parse ]; then VA=(-parse); else VA=(-parse -elabuhdm); fi
    ( cd "$ARM" && "$SL" "${VA[@]}" -nobuiltin -nocache -sv -mt 0 -mp 0 \
        -o "$W" dut.sv ) </dev/null > "$W/sl.log" 2>&1
    rc=$?
    G=$(ls "$W"/slpp_all/*.uhdm "$W"/slpp_unit/*.uhdm 2>/dev/null | head -1)
    if [ $rc -ne 0 ] || [ -z "$G" ]; then
      echo "ARM $rel/$view GOLDEN rc=$rc db=${G:-none} FAILED"
      FAILED=$((FAILED+1))
    else
      "$DUMP" "$G" </dev/null > "$OUT/$rel.$view.golden.dump" 2>"$W/dump.log"
      drc=$?
      echo "ARM $rel/$view GOLDEN rc=$rc dumprc=$drc lines=$(wc -l < "$OUT/$rel.$view.golden.dump")"
      [ $drc -eq 0 ] || FAILED=$((FAILED+1))
    fi
  done
  if [ -n "$OURS" ]; then
    W=$OUT/$rel.ours
    rm -rf "$W"; mkdir -p "$W"
    ( cd "$ARM" && "$OURS" dut.sv -o "$W/slang.uhdm" ) </dev/null \
        > "$W/ours.log" 2>&1
    rc=$?
    if [ $rc -ne 0 ] || [ ! -f "$W/slang.uhdm" ]; then
      echo "ARM $rel/ours OURS rc=$rc FAILED"
      FAILED=$((FAILED+1))
    else
      "$DUMP" "$W/slang.uhdm" </dev/null > "$OUT/$rel.ours.dump" 2>"$W/dump.log"
      drc=$?
      echo "ARM $rel/ours OURS rc=$rc dumprc=$drc lines=$(wc -l < "$OUT/$rel.ours.dump")"
      [ $drc -eq 0 ] || FAILED=$((FAILED+1))
    fi
  fi
  PROCESSED=$((PROCESSED+1))
done
exec 3<&-
echo "LISTED=$LISTED PROCESSED=$PROCESSED FAILED=$FAILED"
[ "$LISTED" -eq "$PROCESSED" ] || { echo "FATAL: LISTED != PROCESSED"; exit 4; }
[ "$FAILED" -eq 0 ] || { echo "GRID HAS FAILING ARMS — an arm whose compile fails teaches error recovery, not golden"; exit 5; }
echo "GRID OK"
