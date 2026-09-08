#!/usr/bin/env bash
# v214 verifier arms, CORRECTED elab column: our binary gets --elabuhdm whenever
# golden gets -elabuhdm (scripts/verify_golden.py:369-370 does exactly that).
set -u
ARMS=${1:?}; SCR=${2:?}; OUT=${3:?}
PRIS=/tmp/v214_pris.bin; PATCHED=/tmp/v214_pat.bin
TS=/tmp/v214_bin/ct214bind
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
mkdir -p "$SCR"; : > "$OUT"
n=0; nog=0
while read -r f <&3; do
  b=$(basename "$f" .sv)
  for ev in parse elab; do
    d=$SCR/$b.$ev; rm -rf "$d"; mkdir -p "$d"; cp "$f" "$d/"
    for h in "$(dirname "$f")"/*.svh; do [ -f "$h" ] && cp "$h" "$d/"; done
    gx=""; ox=""
    if [ "$ev" = elab ]; then gx="-elabuhdm"; ox="--elabuhdm"; fi
    ( cd "$d" && timeout 300 "$SURELOG" -parse -d coveruhdm -nobuiltin -nocache $gx "$b.sv" > sl.log 2>&1 </dev/null ); grc=$?
    ( cd "$d" && timeout 300 "$PRIS"    "$b.sv" $ox -o p.uhdm > p.log 2>&1 </dev/null ); prc=$?
    ( cd "$d" && timeout 300 "$PATCHED" "$b.sv" $ox -o q.uhdm > q.log 2>&1 </dev/null ); qrc=$?
    g=$d/slpp_all/surelog.uhdm
    bytes=SAME; cmp -s "$d/p.uhdm" "$d/q.uhdm" 2>/dev/null || bytes=MOVED
    if [ ! -f "$g" ] || [ ! -f "$d/q.uhdm" ]; then echo "ARM $b $ev golden=NO rc=$grc/$prc/$qrc bytes=$bytes" >> "$OUT"; nog=$((nog+1)); n=$((n+1)); continue; fi
    "$TS" --keycount "$g"        | sort > "$d/g.kc"
    "$TS" --keycount "$d/p.uhdm" | sort > "$d/p.kc"
    "$TS" --keycount "$d/q.uhdm" | sort > "$d/q.kc"
    # golden-vs-golden calibration
    cal=$(comm -3 "$d/g.kc" "$d/g.kc" | wc -l)
    ap=$(comm -12 "$d/g.kc" "$d/p.kc" | wc -l); aq=$(comm -12 "$d/g.kc" "$d/q.kc" | wc -l)
    ogp=$(comm -23 "$d/g.kc" "$d/p.kc" | wc -l); ogq=$(comm -23 "$d/g.kc" "$d/q.kc" | wc -l)
    oop=$(comm -13 "$d/g.kc" "$d/p.kc" | wc -l); ooq=$(comm -13 "$d/g.kc" "$d/q.kc" | wc -l)
    printf "ARM %-16s %-5s rc=%s/%s/%s bytes=%-5s calib=%s AGREE %s->%s ONLYG %s->%s ONLYOURS %s->%s\n" \
      "$b" "$ev" "$grc" "$prc" "$qrc" "$bytes" "$cal" "$ap" "$aq" "$ogp" "$ogq" "$oop" "$ooq" >> "$OUT"
    n=$((n+1))
  done
done 3< <(find "$ARMS" -maxdepth 1 -name '*.sv' | sort)
echo "ARMVIEWS=$n NOGOLDEN=$nog" >> "$OUT"
