#!/usr/bin/env bash
set -u
GB=$1; GP=$2
printf '%-24s %-6s %s\n' CELL VERDICT DETAIL
tot=0;bm=0;pm=0;reg=0;fix=0
for d in "$GB"/*/; do
  c=$(basename "$d"); [ -d "$GP/$c" ] || continue
  [ -s "$d/gold.calls.tsv" ] || { printf '%-24s %s\n' "$c" "NO-GOLDEN-DB"; continue; }
  g=$(awk -F'\t' '$1=="ELAB"{printf "%s=%s@%s;",$3,$6,$7}' "$d/gold.calls.tsv")
  ob=$(awk -F'\t' '$1=="ELAB"{printf "%s=%s@%s;",$3,$6,$7}' "$d/ours.calls.tsv" 2>/dev/null)
  op=$(awk -F'\t' '$1=="ELAB"{printf "%s=%s@%s;",$3,$6,$7}' "$GP/$c/ours.calls.tsv" 2>/dev/null)
  if [ -z "$ob" ] && [ -z "$op" ]; then printf '%-24s %s\n  gold: %s\n' "$c" "NO-SLANG-DB(both)" "$g"; continue; fi
  tot=$((tot+1))
  vb=DIFF; vp=DIFF
  [ "$g" = "$ob" ] && { vb=MATCH; bm=$((bm+1)); }
  [ "$g" = "$op" ] && { vp=MATCH; pm=$((pm+1)); }
  tag="$vb->$vp"
  [ "$vb" = MATCH ] && [ "$vp" = DIFF ] && { tag="REGRESSION"; reg=$((reg+1)); }
  [ "$vb" = DIFF ] && [ "$vp" = MATCH ] && { tag="FIXED"; fix=$((fix+1)); }
  if [ "$vb" = MATCH ] && [ "$vp" = MATCH ]; then printf '%-24s %-6s\n' "$c" "both-OK"
  else printf '%-24s %-6s\n  gold: %s\n  base: %s\n  pat : %s\n' "$c" "$tag" "$g" "$ob" "$op"; fi
done
echo "-- comparable=$tot baseMATCH=$bm patMATCH=$pm REGRESSIONS=$reg FIXED=$fix"
