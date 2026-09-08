#!/usr/bin/env bash
# r10v218 — the VERIFIER's own re-score of boundary movers against a REAL
# Surelog golden.  MEASUREMENT ONLY.  Records the golden's rc LOUDLY: an arm
# whose golden compile FAILED teaches error recovery, not golden (uvm215).
# usage: rescore_v.sh <tree> <scratch> <out> <binA> <binB> <armlist>
set -u
TREE=${1:?}; SCR=${2:?}; OUT=${3:?}; A=${4:?}; B=${5:?}; LIST=${6:?}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CEN=${CENV:-/tmp/v218_cenv.py}
for t in "$A" "$B" "$SURELOG" "$DUMP"; do [ -x "$t" ] || { echo "FATAL: no $t"; exit 3; }; done
[ -f "$LIST" ] || { echo "FATAL: no armlist"; exit 3; }
[ -f "$CEN" ] || { echo "FATAL: no census"; exit 3; }
mkdir -p "$SCR" || exit 1; : > "$OUT"
n=0; nog=0
while read -r rel view <&3; do
  n=$((n+1))
  key=$(echo "$rel" | sed 's|^\./||; s|/|__|g; s|\.sv$||')
  d=$SCR/$key.$view; rm -rf "$d"; mkdir -p "$d" || exit 1
  cp "$TREE/$rel" "$d/" || exit 1
  bn=$(basename "$rel"); ex=""; sx=""
  [ "$view" = elab ] && { ex="-elabuhdm"; sx="--elabuhdm"; }
  ( cd "$d" && timeout 300 "$SURELOG" -parse -d coveruhdm -nobuiltin -nocache $ex "$bn" > sl.log 2>&1 </dev/null ); grc=$?
  ( cd "$d" && timeout 300 "$A" $sx "$bn" -o a.uhdm > a.log 2>&1 </dev/null ); arc=$?
  ( cd "$d" && timeout 300 "$B" $sx "$bn" -o b.uhdm > b.log 2>&1 </dev/null ); brc=$?
  g=$d/slpp_all/surelog.uhdm
  if [ ! -f "$g" ] || [ ! -f "$d/a.uhdm" ] || [ ! -f "$d/b.uhdm" ]; then
    echo "ARM $rel $view rc_sl=$grc rc_a=$arc rc_b=$brc VERDICT=NO-DATABASE" >> "$OUT"
    nog=$((nog+1)); continue
  fi
  gw="GOLDEN-RC-OK"; [ "$grc" != 0 ] && gw="GOLDEN-COMPILE-FAILED-rc=$grc"
  echo "ARM $rel $view rc_sl=$grc rc_a=$arc rc_b=$brc $gw" >> "$OUT"
  "$DUMP" "$g" > "$d/g.dump" 2>&1
  "$DUMP" "$d/a.uhdm" > "$d/a.dump" 2>&1
  "$DUMP" "$d/b.uhdm" > "$d/b.dump" 2>&1
  echo "CALIB $rel $view $(python3 "$CEN" "$d/g.dump" "$d/g.dump" work@ --quiet | tail -1)" >> "$OUT"
  python3 "$CEN" "$d/g.dump" "$d/a.dump" work@ > "$d/cen_a.txt"
  python3 "$CEN" "$d/g.dump" "$d/b.dump" work@ > "$d/cen_b.txt"
  echo "CEN-PRIS $rel $view $(tail -1 "$d/cen_a.txt")" >> "$OUT"
  echo "CEN-PAT  $rel $view $(tail -1 "$d/cen_b.txt")" >> "$OUT"
  diff "$d/cen_a.txt" "$d/cen_b.txt" | sed "s|^|DIFF $rel $view |" >> "$OUT"
  # whole-dump add/remove proof, ids normalised
  sed -E 's/id:[0-9]+/id:N/g' "$d/a.dump" > "$d/a.n"; sed -E 's/id:[0-9]+/id:N/g' "$d/b.dump" > "$d/b.n"
  add=$(diff "$d/a.n" "$d/b.n" | grep -c '^>'); true
  rem=$(diff "$d/a.n" "$d/b.n" | grep -c '^<'); true
  echo "DUMPDELTA $rel $view added=$add removed=$rem" >> "$OUT"
done 3< "$LIST"
echo "-- ARM-VIEWS=$n NO-DATABASE=$nog" >> "$OUT"
tail -1 "$OUT"
