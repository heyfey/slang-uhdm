#!/usr/bin/env bash
# r10uvm168repro/attrib168.sh — ATTRIBUTE every arm the wide boundary reported
# as MOVED.  MEASUREMENT ONLY.
#   attrib168.sh <MOVERS-file> <arms-root> <binA:pristine> <binB:patched> <workroot>
# For each moved arm it builds that arm's OWN Surelog golden and scores the
# param_assign const-type census in all THREE projections (full / ct / rest),
# so a byte mover is never reported as "attributed" on the strength of the byte
# compare alone: the law has to name the cells and say which way they went.
# Scratch is keyed on the arm's RELATIVE path (RESUME §9: several passes name
# their arms the same thing).
set -u
M=${1:?movers file}; ROOT=${2:?arms root}; A=${3:?pristine}; B=${4:?patched}; W=${5:?workroot}
HERE=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$W"
n=0
while read -r rel rest; do
  case "$rel" in RCDIFF) continue;; esac
  f="$ROOT/$rel"
  [ -f "$f" ] || { echo "=== ARM $rel  MISSING-SOURCE"; continue; }
  key=$(echo "$rel" | tr '/.' '__')
  d="$W/$key"; mkdir -p "$d"
  bash "$HERE/grid168.sh" "$f" "$A" "$B" "$d" > "$d.grid.log" 2>&1 || true
  echo "=== ARM $rel   ($rest)"
  for p in full ct rest; do
    bash "$HERE/score168.sh" "$d" pa "$p" | tail -1
  done
  bash "$HERE/score168.sh" "$d" pa full | grep -E '^(TOWARD|AWAY|MOVED-WRONG)' || true
  n=$((n+1))
done < "$M"
echo "ATTRIB arms=$n"
