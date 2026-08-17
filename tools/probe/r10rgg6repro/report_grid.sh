#!/usr/bin/env bash
# r10rgg6/report_grid.sh — the readable grid table: for every cell, GOLDEN's
# and OURS' vpiTypespec verdict on EVERY param-initializer func_call in the
# ELAB view (not just P1), so a cell that agrees on P1 and disagrees three
# lines down cannot read as agreement.
#
#   usage: report_grid.sh <griddir>
set -u
G=${1:?griddir}
tot=0; mat=0; dif=0; nog=0
for d in "$G"/*/; do
  c=$(basename "$d")
  if [ ! -s "$d/gold.calls.tsv" ]; then
    printf '%-42s %s\n' "$c" "NO-GOLDEN-DB"; nog=$((nog+1)); continue
  fi
  g=$(awk -F'\t' '$1=="ELAB"{printf "%s=%s@%s;", $3, $6, $7}' "$d/gold.calls.tsv")
  o=$(awk -F'\t' '$1=="ELAB"{printf "%s=%s@%s;", $3, $6, $7}' "$d/ours.calls.tsv" 2>/dev/null)
  if [ -z "$o" ]; then
    printf '%-42s %s\n  gold: %s\n' "$c" "NO-SLANG-DB" "$g"; nog=$((nog+1)); continue
  fi
  tot=$((tot+1))
  if [ "$g" = "$o" ]; then
    printf '%-42s MATCH  %s\n' "$c" "$g"; mat=$((mat+1))
  else
    printf '%-42s DIFF\n  gold: %s\n  ours: %s\n' "$c" "$g" "$o"; dif=$((dif+1))
  fi
done
echo "-- comparable=$tot MATCH=$mat DIFF=$dif unmeasurable=$nog"
