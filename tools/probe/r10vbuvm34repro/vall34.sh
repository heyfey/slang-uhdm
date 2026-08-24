#!/usr/bin/env bash
# r10vbuvm34repro/vall34.sh — score every arm workdir under $1, both views,
# both families.  MEASUREMENT ONLY.
set -u
R=${1:?arm root}
cd "$(dirname "$0")"
for d in "$R"/*/; do
  a=$(basename "$d")
  for v in def elab; do
    [ -f "$d/dump.g.$v.txt" ] && [ -f "$d/dump.p.$v.txt" ] && [ -f "$d/dump.q.$v.txt" ] || { echo "$a/$v: MISSING"; continue; }
    for fam in FELV REFB; do
      echo -n "$a/$v "
      python3 vscore34.py "$d/dump.g.$v.txt" "$d/dump.p.$v.txt" "$d/dump.q.$v.txt" $fam -q
    done
  done
done
