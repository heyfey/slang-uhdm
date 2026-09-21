#!/usr/bin/env bash
# Per-arm: dump-diff distance to golden on each binary, split into
# OURS-ONLY (lines we write and golden does not) and GOLD-ONLY (lines golden
# writes and we do not).  Any arm whose OURS-ONLY count RISES is a candidate
# MOVED-WRONG; any whose GOLD-ONLY falls moved toward golden.
set -u
GRID=${GRID:?}
printf '%-18s %-28s %-28s %s\n' arm 'pris(gold-only/ours-only)' 'pat(gold-only/ours-only)' verdict
for d in $(ls -d $GRID/*/ | xargs -n1 basename | sort -V); do
  g1=$GRID/$d/gold.pris.dump; o1=$GRID/$d/ours.pris.dump
  g2=$GRID/$d/gold.pat.dump;  o2=$GRID/$d/ours.pat.dump
  [ -f "$g1" ] && [ -f "$o1" ] && [ -f "$g2" ] && [ -f "$o2" ] || { printf '%-18s %s\n' "$d" "MISSING-DUMP"; continue; }
  pg=$(diff <(tail -n +2 $g1) <(tail -n +2 $o1) | grep -c '^<'; true)
  po=$(diff <(tail -n +2 $g1) <(tail -n +2 $o1) | grep -c '^>'; true)
  qg=$(diff <(tail -n +2 $g2) <(tail -n +2 $o2) | grep -c '^<'; true)
  qo=$(diff <(tail -n +2 $g2) <(tail -n +2 $o2) | grep -c '^>'; true)
  v=SAME
  [ "$qo" -gt "$po" ] && v=OURS-ONLY-ROSE
  [ "$qg" -lt "$pg" ] && [ "$qo" -le "$po" ] && v=CLOSER
  [ "$qg" -lt "$pg" ] && [ "$qo" -gt "$po" ] && v=MIXED
  [ "$qg" -gt "$pg" ] && v=GOLD-ONLY-ROSE
  printf '%-18s %-28s %-28s %s\n' "$d" "$pg/$po" "$qg/$qo" "$v"
done
