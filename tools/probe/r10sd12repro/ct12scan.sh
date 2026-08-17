#!/usr/bin/env bash
# r10sd12 — ct12pred over EVERY database of a sweep workdir, pairing each with
# the golden its OWN cmds.txt names.  Carried forward from r10sd11's
# ct11scan.sh together with the three guards those scripts paid for:
#
#   * THE ACCOUNTING GUARD.  Every database found must be accounted for by
#     exactly one of scanned / empty_join / no_golden / no_line, and a mismatch
#     is a hard error (exit 6).  ct10scan.sh's first version scanned 687 of 1358
#     databases and printed a clean `candidates=0` because one `$(( ))` syntax
#     error on a legitimately EMPTY join killed the loop.
#   * AN EMPTY JOIN IS ITS OWN BUCKET — it carries no bucket fields, and letting
#     `$(( ))` swallow it is how a partial scan reads as perfection.
#   * `< /dev/null` on the child, so a tool that reads stdin cannot eat the list.
#
#   usage: PRED=<ct12pred binary> ./ct12scan.sh <workdir root>
set -u
PRED=${PRED:?set PRED to the built ct12pred}
WD=${1:?workdir root}
[ -x "$PRED" ] || { echo "FATAL: no ct12pred at $PRED"; exit 3; }
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
found=0; scanned=0; no_golden=0; no_line=0; empty_join=0; withrows=0
gC=0; gR=0; oC=0; oR=0; eC=0; ot=0
while read -r db; do
  found=$((found+1))
  d=$(dirname "$db")
  C=$d/cmds.txt
  G=""
  [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ]; then no_golden=$((no_golden+1)); continue; fi
  line=$("$PRED" "$G" "$db" 2>/dev/null < /dev/null | grep '^\[S\] ELEM ')
  if [ -z "$line" ]; then no_line=$((no_line+1)); continue; fi
  case "$line" in *EMPTY-JOIN*) empty_join=$((empty_join+1)); continue;; esac
  scanned=$((scanned+1))
  a=$(echo "$line" | sed -n 's/.*G_CLASSVAR=\([0-9]*\).*/\1/p')
  b=$(echo "$line" | sed -n 's/.*G_REFVAR=\([0-9]*\).*/\1/p')
  c=$(echo "$line" | sed -n 's/.*O_CLASSVAR=\([0-9]*\).*/\1/p')
  e=$(echo "$line" | sed -n 's/.*O_REFVAR=\([0-9]*\).*/\1/p')
  f=$(echo "$line" | sed -n 's/.*ELEM_COUNT=\([0-9]*\).*/\1/p')
  h=$(echo "$line" | sed -n 's/.*OTHER=\([0-9]*\).*/\1/p')
  gC=$((gC+a)); gR=$((gR+b)); oC=$((oC+c)); oR=$((oR+e)); eC=$((eC+f)); ot=$((ot+h))
  if [ "$a" -gt 0 ] || [ "$b" -gt 0 ] || [ "$c" -gt 0 ] || [ "$e" -gt 0 ] ||
     [ "$f" -gt 0 ] || [ "$h" -gt 0 ]; then
    withrows=$((withrows+1))
    echo "ROWS $(echo "$d" | sed "s#^$WD/##")  G_CLASSVAR=$a G_REFVAR=$b O_CLASSVAR=$c O_REFVAR=$e ELEM_COUNT=$f OTHER=$h"
  fi
done < <(find "$WD" -name slang.uhdm | sort)
echo "found=$found scanned=$scanned empty_join=$empty_join no_golden=$no_golden no_line=$no_line"
if [ $((scanned+empty_join+no_golden+no_line)) -ne "$found" ]; then
  echo "ACCOUNTING FAILURE: $scanned+$empty_join+$no_golden+$no_line != $found"
  exit 6
fi
echo "[TOTAL] databases=$scanned with_rows=$withrows G_CLASSVAR=$gC G_REFVAR=$gR O_CLASSVAR=$oC O_REFVAR=$oR ELEM_COUNT=$eC OTHER=$ot"
