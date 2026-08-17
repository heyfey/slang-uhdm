#!/usr/bin/env bash
# r10sd11 — ct11pred over EVERY database of a sweep workdir, pairing each with
# the golden its OWN cmds.txt names.  Carried forward from r10sd10's ct10scan.sh
# together with the two guards that script paid for:
#
#   * THE ACCOUNTING GUARD.  Every database found must be accounted for by
#     exactly one of scanned / no_golden / no_line, and a mismatch is a hard
#     error (exit 6).  ct10scan.sh's first version scanned 687 of 1358 databases
#     and printed a clean `candidates=0` because one `$(( ))` syntax error on a
#     legitimately EMPTY join killed the loop.
#   * `< /dev/null` on the child, so a tool that reads stdin cannot eat the list.
#
#   usage: PRED=<ct11pred binary> ./ct11scan.sh <workdir root>
set -u
PRED=${PRED:?set PRED to the built ct11pred}
WD=${1:?workdir root}
[ -x "$PRED" ] || { echo "FATAL: no ct11pred at $PRED"; exit 3; }
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
found=0; scanned=0; no_golden=0; no_line=0; empty_join=0; withrows=0
gU=0; oU=0; kK=0; kN=0; kS=0
while read -r db; do
  found=$((found+1))
  d=$(dirname "$db")
  C=$d/cmds.txt
  G=""
  [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ]; then no_golden=$((no_golden+1)); continue; fi
  line=$("$PRED" "$G" "$db" 2>/dev/null < /dev/null | grep '^\[S\] TS ')
  if [ -z "$line" ]; then no_line=$((no_line+1)); continue; fi
  # An EMPTY JOIN is a legitimate reading (a database with no named variable in
  # common) but it carries NO bucket fields.  ct10scan.sh's first version let
  # the unset `$(( ))` kill its loop and printed a clean score over HALF the
  # corpus; here it is its own counted bucket.
  case "$line" in *EMPTY-JOIN*) empty_join=$((empty_join+1)); continue;; esac
  scanned=$((scanned+1))
  a=$(echo "$line" | sed -n 's/.*G_UNSUP=\([0-9]*\).*/\1/p')
  b=$(echo "$line" | sed -n 's/.*O_UNSUP=\([0-9]*\).*/\1/p')
  c=$(echo "$line" | sed -n 's/.*TS_KIND=\([0-9]*\).*/\1/p')
  e=$(echo "$line" | sed -n 's/.*TS_NAME=\([0-9]*\).*/\1/p')
  f=$(echo "$line" | sed -n 's/.*TS_SPAN=\([0-9]*\).*/\1/p')
  gU=$((gU+a)); oU=$((oU+b)); kK=$((kK+c)); kN=$((kN+e)); kS=$((kS+f))
  if [ "$a" -gt 0 ] || [ "$b" -gt 0 ]; then
    withrows=$((withrows+1))
    echo "ROWS $(echo "$d" | sed "s#^$WD/##")  G_UNSUP=$a O_UNSUP=$b"
  fi
done < <(find "$WD" -name slang.uhdm | sort)
echo "found=$found scanned=$scanned empty_join=$empty_join no_golden=$no_golden no_line=$no_line"
if [ $((scanned+empty_join+no_golden+no_line)) -ne "$found" ]; then
  echo "ACCOUNTING FAILURE: $scanned+$empty_join+$no_golden+$no_line != $found"
  exit 6
fi
echo "[TOTAL] databases=$scanned with_unsup_rows=$withrows G_UNSUP=$gU O_UNSUP=$oU TS_KIND=$kK TS_NAME=$kN TS_SPAN=$kS"
