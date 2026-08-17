#!/usr/bin/env bash
# compare GOLDEN vs base vs patched over ALL views (DEF+ELAB+OTHER), keyed by
# view/lhs/fn/loc -> ts. A view golden lacks is reported, never silently dropped.
set -u
GB=$1; GP=$2
tot=0;bm=0;pm=0;reg=0;fix=0;nog=0
key() { awk -F'\t' '{printf "%s|%s|%s=%s@%s;",$1,$3,$4,$6,$7}' "$1" 2>/dev/null; }
for d in "$GB"/*/; do
  c=$(basename "$d"); [ -d "$GP/$c" ] || continue
  if [ ! -f "$d/gold.dump" ]; then printf '%-24s NO-GOLDEN-DB\n' "$c"; nog=$((nog+1)); continue; fi
  if [ ! -f "$d/slang.uhdm" ] || [ ! -f "$GP/$c/slang.uhdm" ]; then printf '%-24s NO-SLANG-DB\n' "$c"; nog=$((nog+1)); continue; fi
  g=$(key "$d/gold.calls.tsv"); ob=$(key "$d/ours.calls.tsv"); op=$(key "$GP/$c/ours.calls.tsv")
  tot=$((tot+1)); vb=DIFF; vp=DIFF
  [ "$g" = "$ob" ] && { vb=MATCH; bm=$((bm+1)); }
  [ "$g" = "$op" ] && { vp=MATCH; pm=$((pm+1)); }
  tag="$vb/$vp"
  [ "$vb" = MATCH ] && [ "$vp" = DIFF ] && { tag="*** REGRESSION ***"; reg=$((reg+1)); }
  [ "$vb" = DIFF ] && [ "$vp" = MATCH ] && { tag="FIXED"; fix=$((fix+1)); }
  if [ "$ob" != "$op" ] || [ "$vb" != MATCH ] || [ "$vp" != MATCH ]; then
    printf '%-24s %s\n  gold: %s\n  base: %s\n  pat : %s\n' "$c" "$tag" "$g" "$ob" "$op"
  else printf '%-24s both-OK\n' "$c"; fi
done
echo "-- comparable=$tot baseMATCH=$bm patMATCH=$pm REGRESSIONS=$reg FIXED=$fix unmeasurable=$nog"
