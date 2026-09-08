#!/usr/bin/env bash
# v214 verifier — re-score every boundary mover against a REAL Surelog golden in
# BOTH views, with our binary given --elabuhdm in the elab column (which
# scripts/verify_golden.py:369-370 does and armscore214.sh/grid214.sh do NOT).
set -u
MOV=${1:?}; ROOT=${2:?}; SCR=${3:?}; OUT=${4:?}
PRIS=/tmp/v214_pris.bin; PATCHED=/tmp/v214_pat.bin; TS=/tmp/v214_bin/ct214bind
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
mkdir -p "$SCR"; : > "$OUT"; n=0; nog=0; tg=0; aw=0
while read -r rel rest <&3; do
  case "$rel" in RCDIFF) continue ;; esac
  f=$ROOT/$rel; [ -f "$f" ] || { echo "ARM $rel MISSING-SOURCE" >> "$OUT"; continue; }
  b=$(basename "$f" .sv)
  for ev in parse elab; do
    key=$(echo "$rel.$ev" | tr '/' '_'); d=$SCR/$key; rm -rf "$d"; mkdir -p "$d"
    cp "$f" "$d/"
    for h in "$(dirname "$f")"/*.svh "$(dirname "$f")"/*.vh; do [ -f "$h" ] && cp "$h" "$d/"; done
    gx=""; ox=""; [ "$ev" = elab ] && { gx="-elabuhdm"; ox="--elabuhdm"; }
    ( cd "$d" && timeout 300 "$SURELOG" -parse -d coveruhdm -nobuiltin -nocache $gx "$b.sv" >sl.log 2>&1 </dev/null ); grc=$?
    ( cd "$d" && timeout 300 "$PRIS"    "$b.sv" $ox -o p.uhdm >p.log 2>&1 </dev/null ); prc=$?
    ( cd "$d" && timeout 300 "$PATCHED" "$b.sv" $ox -o q.uhdm >q.log 2>&1 </dev/null ); qrc=$?
    g=$d/slpp_all/surelog.uhdm
    if [ ! -f "$g" ] || [ ! -f "$d/q.uhdm" ] || [ ! -f "$d/p.uhdm" ]; then
      echo "ARM $rel $ev golden=NO rc=$grc/$prc/$qrc" >> "$OUT"; nog=$((nog+1)); n=$((n+1)); continue; fi
    "$TS" --keycount "$g" | sort > "$d/g.kc"; "$TS" --keycount "$d/p.uhdm" | sort > "$d/p.kc"; "$TS" --keycount "$d/q.uhdm" | sort > "$d/q.kc"
    cal=$(comm -3 "$d/g.kc" "$d/g.kc" | wc -l)
    lost=$(comm -12 "$d/g.kc" "$d/p.kc" | comm -23 - "$d/q.kc" | wc -l)
    gain=$(comm -12 "$d/g.kc" "$d/q.kc" | comm -23 - "$d/p.kc" | wc -l)
    bytes=SAME; cmp -s "$d/p.uhdm" "$d/q.uhdm" || bytes=MOVED
    printf "ARM %-34s %-5s rc=%s/%s/%s bytes=%-5s calib=%s AGREE %s->%s ONLYG %s->%s ONLYOURS %s->%s TO-GOLDEN=%s AWAY/MOVED-WRONG=%s\n" \
      "$rel" "$ev" "$grc" "$prc" "$qrc" "$bytes" "$cal" \
      "$(comm -12 "$d/g.kc" "$d/p.kc" | wc -l)" "$(comm -12 "$d/g.kc" "$d/q.kc" | wc -l)" \
      "$(comm -23 "$d/g.kc" "$d/p.kc" | wc -l)" "$(comm -23 "$d/g.kc" "$d/q.kc" | wc -l)" \
      "$(comm -13 "$d/g.kc" "$d/p.kc" | wc -l)" "$(comm -13 "$d/g.kc" "$d/q.kc" | wc -l)" \
      "$gain" "$lost" >> "$OUT"
    tg=$((tg+gain)); aw=$((aw+lost)); n=$((n+1))
  done
done 3< "$MOV"
echo "ARMVIEWS=$n NOGOLDEN=$nog TOTAL_TO-GOLDEN=$tg TOTAL_AWAY_OR_MOVED-WRONG=$aw" >> "$OUT"
