#!/usr/bin/env bash
# r10uvm203repro/bscore203.sh — SCORE EVERY ARM THE WIDE BOUNDARY MOVED
# AGAINST A REAL SURELOG GOLDEN, in BOTH views.  MEASUREMENT ONLY.
#
# A moved arm is not a defect and not a pass; it is a claim that has to be
# settled by golden.  For each arm named in the boundary's MOVERS file this
# rebuilds a real Surelog golden and runs ct203cen's compare-visible census
# against the PRISTINE and the PATCHED database, then prints, per view,
#   AGREE      pristine -> patched      (TO-GOLDEN = the rise)
#   TS-DIFF  pristine -> patched
#   ONLY-GOLDEN / ONLY-OURS  pristine -> patched  (must never rise)
# A FALL in AGREE, or a RISE in either one-sided set, is AWAY-GOLDEN.
# Every rc is recorded; an arm Surelog or our binary cannot build is NAMED.
#
#   usage: PRIS=.. PATCHED=.. CEN=.. JOIN=.. bscore203.sh <arms root> <MOVERS file> <outdir>
set -u
SRC=$(readlink -f "${1:?arms root}"); MOV=${2:?MOVERS file}; OUT=$(readlink -f "${3:?outdir}")
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}; CEN=${CEN:?}; JOIN=${JOIN:?}
SL=$HOME/git-repos/Surelog/build/bin/surelog
mkdir -p "$OUT"; : > "$OUT/SCORES"
tg=0; aw=0; n=0; miss=0; nodb=0
fld() { printf '%s' "$1" | sed "s/.*$2=\([0-9-]*\).*/\1/"; }
while read -r rel rest <&3; do
  [ -z "$rel" ] && continue
  case "$rel" in RCDIFF*) continue;; esac
  f="$SRC/$rel"
  [ -f "$f" ] || { echo "MISSING-ARM $rel" >> "$OUT/SCORES"; miss=$((miss+1)); continue; }
  key=$(echo "$rel" | tr '/' '_'); W="$OUT/$key.d"; mkdir -p "$W"
  cp "$f" "$W/" 2>/dev/null
  for h in "$(dirname "$f")"/*.svh "$(dirname "$f")"/*.vh; do [ -f "$h" ] && cp "$h" "$W/"; done
  b=$(basename "$f")
  for v in def elab; do
    EF=""; SF=""
    [ "$v" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
    ( cd "$W" && "$SL" -parse -nocache -nowritecache -noprecompiledcache -d coveruhdm $SF -o "$W/g_$v" "$b" >/dev/null 2>&1 </dev/null ); grc=$?
    ( cd "$W" && "$PRIS"    "$b" $EF -o "$W/a_$v.uhdm" >/dev/null 2>&1 </dev/null ); arc=$?
    ( cd "$W" && "$PATCHED" "$b" $EF -o "$W/b_$v.uhdm" >/dev/null 2>&1 </dev/null ); brc=$?
    G="$W/g_$v/slpp_all/surelog.uhdm"
    if [ ! -f "$G" ] || [ ! -f "$W/a_$v.uhdm" ] || [ ! -f "$W/b_$v.uhdm" ]; then
      echo "NODB $rel $v grc=$grc arc=$arc brc=$brc" >> "$OUT/SCORES"; nodb=$((nodb+1)); continue
    fi
    "$CEN" "$G" > "$W/g_$v.cells" 2>/dev/null
    "$CEN" "$W/a_$v.uhdm" > "$W/a_$v.cells" 2>/dev/null
    "$CEN" "$W/b_$v.uhdm" > "$W/b_$v.cells" 2>/dev/null
    ga=$(python3 "$JOIN" "$W/g_$v.cells" "$W/a_$v.cells")
    gb=$(python3 "$JOIN" "$W/g_$v.cells" "$W/b_$v.cells")
    pa=$(fld "$ga" AGREE); qa=$(fld "$gb" AGREE)
    ps=$(fld "$ga" WRONG); qs=$(fld "$gb" WRONG)
    pgo=$(fld "$ga" ONLY-GOLDEN); qgo=$(fld "$gb" ONLY-GOLDEN)
    poo=$(fld "$ga" ONLY-OURS);   qoo=$(fld "$gb" ONLY-OURS)
    d=$((qa-pa))
    away=0
    [ "$d" -lt 0 ] && away=$((-d))
    [ "$qgo" -gt "$pgo" ] && away=$((away+qgo-pgo))
    [ "$qoo" -gt "$poo" ] && away=$((away+qoo-poo))
    printf "%s\t%s\tAGREE %s->%s\tWRONG %s->%s\tONLY-G %s->%s\tONLY-O %s->%s\tTO-GOLDEN %d\tAWAY %d\trc=%s/%s/%s\n" \
      "$rel" "$v" "$pa" "$qa" "$ps" "$qs" "$pgo" "$qgo" "$poo" "$qoo" \
      "$([ "$d" -gt 0 ] && echo "$d" || echo 0)" "$away" "$grc" "$arc" "$brc" >> "$OUT/SCORES"
    [ "$d" -gt 0 ] && tg=$((tg+d))
    aw=$((aw+away)); n=$((n+1))
  done
  rm -rf "$W/g_def" "$W/g_elab" "$W"/*.uhdm "$W"/*.cells
done 3< <(awk 'NF{print $1}' "$MOV")
echo "-- SCORED views=$n MISSING-ARMS=$miss NODB-views=$nodb TO-GOLDEN=$tg AWAY-GOLDEN=$aw"
