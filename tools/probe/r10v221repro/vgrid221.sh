#!/bin/bash
# r10v221repro/vgrid221.sh — THE VERIFIER'S OWN GOLDEN GRID for
# § uninstIfaceEnumConstNoActual221.  Written independently of the
# implementer's grid221.sh so a flaw in that harness cannot be inherited.
#
#   usage: vgrid221.sh <outdir> <pristine-binary> <patched-binary>
#
# Per arm it builds THREE databases in TWO golden views:
#   golden  parse  (-parse)            — the corpus row's own view
#   golden  elab   (-parse -elabuhdm)  — the elaborated view
#   ours    pristine, ours patched
# EVERY rc is recorded.  An arm whose compile FAILS teaches error recovery, not
# golden (uvm215), so a non-zero rc counts as FAILED and never as agreement.
# The file list is read on fd 3 with every child </dev/null (sd8-12's
# stdin-swallow trap); scratch is keyed on the arm's RELATIVE path; PROCESSED
# is asserted against LISTED.
set -u
OUT=${1:?outdir}
PRIS=${2:?pristine binary}
PAT=${3:?patched binary}
HERE=$(cd "$(dirname "$0")" && pwd)
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}   # the path scripts/verify_golden.py names
DUMP=${UHDMDUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
[ -x "$SL" ]   || { echo "FATAL: no surelog at $SL"; exit 3; }
[ -x "$DUMP" ] || { echo "FATAL: no uhdm-dump at $DUMP"; exit 3; }
[ -x "$PRIS" ] || { echo "FATAL: no binary at $PRIS"; exit 3; }
[ -x "$PAT" ]  || { echo "FATAL: no binary at $PAT"; exit 3; }
mkdir -p "$OUT" || exit 1

LISTED=0; PROCESSED=0; FAILED=0
find "$HERE/arms" -mindepth 1 -maxdepth 1 -type d | sort > "$OUT/.arms.txt"
LISTED=$(wc -l < "$OUT/.arms.txt")
exec 3< "$OUT/.arms.txt"
while read -r ARM <&3; do
  rel=$(basename "$ARM")
  for view in parse elab; do
    W=$OUT/$rel.$view; rm -rf "$W"; mkdir -p "$W"
    if [ "$view" = parse ]; then VA=(-parse); else VA=(-parse -elabuhdm); fi
    ( cd "$ARM" && "$SL" "${VA[@]}" -nobuiltin -nocache -sv -mt 0 -mp 0 \
        -o "$W" dut.sv ) </dev/null > "$W/sl.log" 2>&1
    rc=$?
    G=$(ls "$W"/slpp_all/*.uhdm "$W"/slpp_unit/*.uhdm 2>/dev/null | head -1)
    if [ $rc -ne 0 ] || [ -z "$G" ]; then
      echo "ARM $rel/$view GOLDEN rc=$rc db=${G:-none} FAILED"; FAILED=$((FAILED+1))
    else
      "$DUMP" "$G" </dev/null > "$OUT/$rel.$view.golden.dump" 2>"$W/dump.log"; drc=$?
      echo "ARM $rel/$view GOLDEN rc=$rc dumprc=$drc lines=$(wc -l < "$OUT/$rel.$view.golden.dump")"
      [ $drc -eq 0 ] || FAILED=$((FAILED+1))
    fi
  done
  for side in pris pat; do
    if [ "$side" = pris ]; then B=$PRIS; else B=$PAT; fi
    W=$OUT/$rel.$side; rm -rf "$W"; mkdir -p "$W"
    ( cd "$ARM" && "$B" dut.sv -o "$W/slang.uhdm" ) </dev/null > "$W/ours.log" 2>&1
    rc=$?
    if [ $rc -ne 0 ] || [ ! -f "$W/slang.uhdm" ]; then
      echo "ARM $rel/$side OURS rc=$rc FAILED"; FAILED=$((FAILED+1))
    else
      "$DUMP" "$W/slang.uhdm" </dev/null > "$OUT/$rel.$side.dump" 2>"$W/dump.log"; drc=$?
      echo "ARM $rel/$side OURS rc=$rc dumprc=$drc lines=$(wc -l < "$OUT/$rel.$side.dump")"
      [ $drc -eq 0 ] || FAILED=$((FAILED+1))
    fi
  done
  PROCESSED=$((PROCESSED+1))
done
exec 3<&-
echo "LISTED=$LISTED PROCESSED=$PROCESSED FAILED=$FAILED"
[ "$LISTED" -eq "$PROCESSED" ] || { echo "FATAL: LISTED != PROCESSED"; exit 4; }
[ "$FAILED" -eq 0 ] || { echo "FATAL: GRID HAS FAILING ARMS"; exit 5; }
echo "VGRID OK"
