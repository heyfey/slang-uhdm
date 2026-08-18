#!/usr/bin/env bash
# r10earl65 — SCORE every boundary mover AGAINST GOLDEN (never merely list it):
# Surelog + both frozen binaries + tscen65 + score65.py, one arm per line.
# MEASUREMENT ONLY.  usage:
#   PATCHED_BIN=.. PRISTINE_BIN=.. PROBE_ROOT=.. armscore65.sh <difflist> <out>
set -u
PAT=${PATCHED_BIN:?}; PRIS=${PRISTINE_BIN:?}; ROOT=${PROBE_ROOT:?}
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CEN=${TSCEN65:-/tmp/r10earl65_tscen65}
SCORE=$(dirname "$0")/score65.py
IN=$1; OUT=$2
STAGE=/tmp/r10earl65_armscore/$$; mkdir -p "$STAGE"
: > "$OUT"
while read -r view rel <&3; do
  [ "$view" = plain ] || continue          # score each file once
  f="$ROOT/$rel"
  key=$(echo "$rel" | tr '/' '_'); key=${key%.sv}
  d="$STAGE/$key"; mkdir -p "$d"; cp "$f" "$d/" || continue
  b=$(basename "$f")
  ( cd "$d" && "$SL" -parse -nobuiltin -nocache -d uhdm "$b" >sl.log 2>&1 </dev/null )
  G="$d/slpp_all/surelog.uhdm"
  [ -f "$G" ] || { echo "$rel SURELOG_FAIL" >> "$OUT"; continue; }
  ( cd "$d" && "$PAT" "$b" -o pat.uhdm >p.log 2>&1 </dev/null )
  ( cd "$d" && "$PRIS" "$b" -o pris.uhdm >o.log 2>&1 </dev/null )
  [ -f "$d/pat.uhdm" ] && [ -f "$d/pris.uhdm" ] || { echo "$rel NO_DB" >> "$OUT"; continue; }
  R65_INST=1 "$CEN" "$G" | sort > "$d/g.ex"
  R65_INST=1 "$CEN" "$d/pris.uhdm" | sort > "$d/o.ex"
  R65_INST=1 "$CEN" "$d/pat.uhdm"  | sort > "$d/p.ex"
  echo "$rel $(python3 "$SCORE" "$d/g.ex" "$d/o.ex" "$d/p.ex" 5 0 | head -1)" >> "$OUT"
done 3< "$IN"
cat "$OUT"
