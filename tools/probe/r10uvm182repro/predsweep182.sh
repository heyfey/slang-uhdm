#!/usr/bin/env bash
# r10uvm182repro/predsweep182.sh — run ct182pred over EVERY database of a
# PRISTINE verify_golden workdir and name the predicted movers BY DATABASE,
# before the patched sweep exists.  MEASUREMENT ONLY.
#   predsweep182.sh <pristine-workdir> <out.txt>
# Prints, at the end, the databases with a nonzero candidate count and the
# number of databases SCANNED — a scan that reached nothing must never read as
# "no movers".
set -u
WD=${1:?workdir}; OUT=${2:?out}
HERE=$(cd "$(dirname "$0")" && pwd)
P=$HERE/ct182pred
[ -x "$P" ] || { echo "FATAL: build ct182pred first"; exit 3; }
: > "$OUT"
n=0; hit=0
while IFS= read -r db; do
  n=$((n+1))
  echo "== $db" >> "$OUT"
  "$P" "$db" >> "$OUT" 2>&1
done < <(find "$WD" -name 'slang.uhdm' | sort)
hit=$(grep -c '^CANDIDATES [1-9]' "$OUT" || true)
echo "-- databases scanned=$n  databases with candidates=$hit"
grep '^CANDIDATES [1-9]' "$OUT" || true
