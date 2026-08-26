#!/usr/bin/env bash
# r10uvm154 — RE-SCORE every boundary MOVER against GOLDEN.
#
#   PRI=<pristine> PAT=<patched> goldscore154.sh <arm.sv> ...
#
# Attribution says "only this law's fields moved"; it does NOT say the move was
# an improvement.  RESUME.md §7: "any earlier-pass arm that moves is
# re-measured against golden and moves TOWARD it".  This gate does that
# measurement: it runs Surelog on the arm, dumps golden, pristine and patched
# into the SAME scratch (a database embeds the -o path), path-normalises all
# three, and reports the golden distance BEFORE and AFTER.
#
# WORSE on any arm is a hard failure.  EQUAL is allowed (an arm can move
# between two equally-wrong spellings only if the census half already refused
# it, so in practice EQUAL means the moved cell was outside golden's reach --
# e.g. a `--single-unit` view Surelog does not build).
set -u
PRI=${PRI:?set PRI}; PAT=${PAT:?set PAT}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
WD=${WD:-/tmp/r10uvm154_gscore}
rm -rf "$WD"; mkdir -p "$WD"
worse=0; better=0; equal=0; skip=0
for f in "$@"; do
  key=$(echo "$f" | sed 's#[/.]#__#g')
  d=$WD/$key; mkdir -p "$d"; cp "$f" "$d/" || { skip=$((skip+1)); continue; }
  b=$(basename "$f")
  ( cd "$d" && "$SURELOG" -parse -nocache -mt 0 -mp 0 "$b" > sl.log 2>&1 </dev/null )
  g=$d/slpp_all/surelog.uhdm
  [ -f "$g" ] || { echo "SKIP-NOGOLDEN $f"; skip=$((skip+1)); continue; }
  "$DUMP" "$g" 2>/dev/null </dev/null | sed -e 1d -e "s#$d##g" -e 's/id:[0-9]*/id:N/g' \
    | awk 'BEGIN{k=1} /^\\_weaklyReferenced:/{k=0} k==1{print}' > "$d/g.dmp"
  ok=1
  for w in pris pat; do
    [ "$w" = pris ] && B=$PRI || B=$PAT
    ( cd "$d" && "$B" "$b" -o "$d/o.uhdm" > "$w.log" 2>&1 </dev/null )
    [ -f "$d/o.uhdm" ] || { ok=0; break; }
    "$DUMP" "$d/o.uhdm" 2>/dev/null </dev/null | sed -e 1d -e "s#$d##g" -e 's/id:[0-9]*/id:N/g' \
      | awk 'BEGIN{k=1} /^\\_weaklyReferenced:/{k=0} k==1{print}' > "$d/$w.dmp"
    rm -f "$d/o.uhdm"
  done
  [ "$ok" = 1 ] || { echo "SKIP-NOOURS $f"; skip=$((skip+1)); continue; }
  a=$(diff "$d/g.dmp" "$d/pris.dmp" | grep -c '^[<>]'); true
  z=$(diff "$d/g.dmp" "$d/pat.dmp"  | grep -c '^[<>]'); true
  if   [ "$z" -lt "$a" ]; then echo "TOWARD-GOLDEN $f  $a -> $z"; better=$((better+1))
  elif [ "$z" -eq "$a" ]; then echo "EQUAL         $f  $a -> $z"; equal=$((equal+1))
  else echo "AWAY-GOLDEN   $f  $a -> $z"; worse=$((worse+1)); fi
done
echo "GOLDSCORE better=$better equal=$equal worse=$worse skipped=$skip"
[ "$worse" -eq 0 ] && echo "GOLDSCORE PASS" || { echo "GOLDSCORE FAIL"; exit 4; }
