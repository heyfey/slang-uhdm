#!/usr/bin/env bash
# r10uvm196repro/bscore196.sh — SCORE EVERY ARM THE WIDE BOUNDARY MOVED
# AGAINST A REAL SURELOG GOLDEN, in BOTH views.  MEASUREMENT ONLY.
#
# A moved arm is not a defect and not a pass; it is a claim that has to be
# settled by golden.  For each arm named in the boundary's MOVERS file this
# rebuilds a real Surelog golden and runs ct196cen's compare-visible census
# against the PRISTINE and the PATCHED database, then prints
#   TO-GOLDEN   = pristine GOLDEN-ONLY-COUNT - patched GOLDEN-ONLY-COUNT
#   AWAY-GOLDEN = patched OURS-ONLY-COUNT   - pristine OURS-ONLY-COUNT
# Every rc is recorded; an arm Surelog or our binary cannot build is NAMED.
#
#   usage: PRIS=.. PATCHED=.. CEN=.. bscore196.sh <arms root> <MOVERS file> <outdir>
set -u
SRC=$(readlink -f "${1:?arms root}"); MOV=${2:?MOVERS file}; OUT=$(readlink -f "${3:?outdir}")
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}; CEN=${CEN:?}
SL=$HOME/git-repos/Surelog/build/bin/surelog
mkdir -p "$OUT"; : > "$OUT/SCORES"
tg=0; aw=0; n=0; miss=0
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
      echo "NODB $rel $v grc=$grc arc=$arc brc=$brc" >> "$OUT/SCORES"; continue
    fi
    ga=$("$CEN" --cen "$G" "$W/a_$v.uhdm" "$rel/$v/pris" 2>&1 | grep '^CENSUM')
    gb=$("$CEN" --cen "$G" "$W/b_$v.uhdm" "$rel/$v/pat"  2>&1 | grep '^CENSUM')
    pg=$(printf '%s' "$ga" | sed 's/.*GOLDEN-ONLY-COUNT=\([0-9]*\).*/\1/')
    po=$(printf '%s' "$ga" | sed 's/.*OURS-ONLY-COUNT=\([0-9]*\).*/\1/')
    qg=$(printf '%s' "$gb" | sed 's/.*GOLDEN-ONLY-COUNT=\([0-9]*\).*/\1/')
    qo=$(printf '%s' "$gb" | sed 's/.*OURS-ONLY-COUNT=\([0-9]*\).*/\1/')
    printf "%s\t%s\tgolden-only %s->%s\tours-only %s->%s\tTO-GOLDEN %d\tAWAY %d\trc=%s/%s/%s\n" \
      "$rel" "$v" "$pg" "$qg" "$po" "$qo" "$((pg-qg))" "$((qo-po))" "$grc" "$arc" "$brc" >> "$OUT/SCORES"
    tg=$((tg+pg-qg)); aw=$((aw+qo-po)); n=$((n+1))
  done
  rm -rf "$W/g_def" "$W/g_elab" "$W"/*.uhdm
done 3< <(awk 'NF{print $1}' "$MOV")
echo "-- SCORED views=$n MISSING-ARMS=$miss TO-GOLDEN=$tg AWAY-GOLDEN=$aw"
grep -c NODB "$OUT/SCORES" | sed 's/^/-- NODB views: /'
