#!/usr/bin/env bash
# r10uvm220 — THE AGAINST-GOLDEN RE-SCORE OF EVERY BOUNDARY MOVER.
# MEASUREMENT ONLY.  A moved arm is not a regression and it is not a win; it is
# a question.  This driver answers it the only way that counts: it builds the
# GOLDEN database for the arm in BOTH views and scores the PRISTINE and the
# PATCHED database against it with cen220.py, so every mover is classified
# TOWARD-GOLDEN / AWAY-FROM-GOLDEN / NEITHER by name.
#
#   usage: armscore220.sh <probe-tree> <scratch> <out> <binPristine> <binPatched> <arm> [<arm> ...]
#          <arm> is a path RELATIVE to <probe-tree>.
#
# Every rc is recorded; an arm whose golden or whose either binary fails to
# compile is printed as FAILED and never counted as agreement.
set -u
TREE=${1:?probe tree}; SCR=${2:?scratch}; OUT=${3:?out}
A=${4:?pristine}; B=${5:?patched}
shift 5
SL=$HOME/git-repos/Surelog/build/bin/surelog     # the path scripts/verify_golden.py names
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
HERE=$(cd "$(dirname "$0")" && pwd)
for x in "$SL" "$DUMP" "$A" "$B"; do
  [ -x "$x" ] || { echo "FATAL: not executable: $x"; exit 3; }
done
rm -rf "$SCR"; mkdir -p "$SCR" || exit 1
: > "$OUT"
listed=0; proc=0; failed=0
printf '%s\n' "$@" > "$SCR/arms.txt"
listed=$(wc -l < "$SCR/arms.txt")
exec 3< "$SCR/arms.txt"
while read -r rel <&3; do
  src=$TREE/$rel
  [ -f "$src" ] || { echo "FAILED $rel NO-SUCH-FILE" >> "$OUT"; failed=$((failed+1)); continue; }
  key=$(echo "$rel" | sed 's|^\./||; s|/|__|g; s|\.sv$||')   # keyed on the RELATIVE path
  d=$SCR/$key; mkdir -p "$d/src" || exit 1
  cp "$src" "$d/src/arm.sv"
  for view in parse elab; do
    if [ "$view" = parse ]; then VA=(-parse); XO=""; else VA=(-parse -elabuhdm); XO="--elabuhdm"; fi
    G=$d/g.$view; rm -rf "$G"; mkdir -p "$G"
    ( cd "$d/src" && "$SL" "${VA[@]}" -nobuiltin -nocache -sv -mt 0 -mp 0 -o "$G" arm.sv ) \
        </dev/null > "$G/sl.log" 2>&1
    grc=$?
    gdb=$(ls "$G"/slpp_all/*.uhdm "$G"/slpp_unit/*.uhdm 2>/dev/null | head -1)
    ( cd "$d/src" && "$A" $XO arm.sv -o "$d/a.$view.uhdm" ) </dev/null > "$d/a.$view.log" 2>&1
    arc=$?
    ( cd "$d/src" && "$B" $XO arm.sv -o "$d/b.$view.uhdm" ) </dev/null > "$d/b.$view.log" 2>&1
    brc=$?
    # Surelog exits 4 when it RECOVERED from semantic errors but still wrote a
    # database.  Three of the committed arms this law moves are deliberately
    # adversarial and golden reports `Undefined variable` on them; the SAME
    # golden is then scored against BOTH our binaries, so TOWARD/AWAY is still
    # measured — but the arm is LABELLED, never silently counted as clean
    # SystemVerilog (uvm215's lesson).  A missing database, or either of OUR
    # binaries failing, is still FAILED.
    note=""
    if [ $grc -eq 4 ] && [ -n "$gdb" ] && [ -f "$gdb" ]; then
      note=" [GOLDEN-RECOVERED-ERRORS grc=4: $(grep -c '^\[ERR' "$G/sl.log"; true) errors]"
      grc=0
    fi
    if [ $grc -ne 0 ] || [ -z "$gdb" ] || [ $arc -ne 0 ] || [ $brc -ne 0 ] \
       || [ ! -f "$d/a.$view.uhdm" ] || [ ! -f "$d/b.$view.uhdm" ]; then
      echo "FAILED $rel $view grc=$grc arc=$arc brc=$brc golden=${gdb:-none}" >> "$OUT"
      failed=$((failed+1)); continue
    fi
    "$DUMP" "$gdb"             </dev/null > "$d/g.$view.dump" 2>/dev/null
    "$DUMP" "$d/a.$view.uhdm"  </dev/null > "$d/a.$view.dump" 2>/dev/null
    "$DUMP" "$d/b.$view.uhdm"  </dev/null > "$d/b.$view.dump" 2>/dev/null
    pa=$(python3 "$HERE/cen220.py" --diff "$d/g.$view.dump" "$d/a.$view.dump" | tail -1)
    pb=$(python3 "$HERE/cen220.py" --diff "$d/g.$view.dump" "$d/b.$view.dump" | tail -1)
    sa=$(echo "$pa" | sed 's/.*SAME=\([0-9]*\).*/\1/')
    sb=$(echo "$pb" | sed 's/.*SAME=\([0-9]*\).*/\1/')
    if   [ "$sb" -gt "$sa" ]; then v=TOWARD-GOLDEN
    elif [ "$sb" -lt "$sa" ]; then v=AWAY-FROM-GOLDEN
    else v=NEITHER; fi
    echo "SCORE $rel $view $v  pristine[$pa]  patched[$pb]$note" >> "$OUT"
    # name every cell that changed side, so AWAY can never hide inside a total
    python3 "$HERE/cen220.py" --diff "$d/g.$view.dump" "$d/a.$view.dump" | grep -E '^(MISSING|EXTRA)' | sort > "$d/pris.cells"
    python3 "$HERE/cen220.py" --diff "$d/g.$view.dump" "$d/b.$view.dump" | grep -E '^(MISSING|EXTRA)' | sort > "$d/pat.cells"
    comm -23 "$d/pris.cells" "$d/pat.cells" | sed "s|^|  FIXED   $rel $view |" >> "$OUT"
    comm -13 "$d/pris.cells" "$d/pat.cells" | sed "s|^|  BROKEN  $rel $view |" >> "$OUT"
  done
  proc=$((proc+1))
done
exec 3<&-
echo "-- LISTED=$listed PROCESSED=$proc FAILED=$failed" >> "$OUT"
echo "-- TOWARD=$(grep -c 'TOWARD-GOLDEN' "$OUT"; true) AWAY=$(grep -c 'AWAY-FROM-GOLDEN' "$OUT"; true) NEITHER=$(grep -c ' NEITHER ' "$OUT"; true)" >> "$OUT"
echo "-- BROKEN-CELLS=$(grep -c '^  BROKEN' "$OUT"; true) FIXED-CELLS=$(grep -c '^  FIXED' "$OUT"; true)" >> "$OUT"
tail -3 "$OUT"
[ "$listed" -eq "$proc" ] || { echo "FATAL: LISTED != PROCESSED"; exit 4; }
