#!/usr/bin/env bash
# r10earl64 — SCORE every PER-DIRECTORY boundary mover AGAINST GOLDEN.
# Surelog + both frozen binaries + excen64 + score64.py, --single-unit.
# MEASUREMENT ONLY.  usage:
#   PATCHED_BIN=.. PRISTINE_BIN=.. PROBE_ROOT=.. dirscore64.sh <difflist> <out>
set -u
PAT=${PATCHED_BIN:?}; PRIS=${PRISTINE_BIN:?}; ROOT=${PROBE_ROOT:?}
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CEN=${EXCEN64:-/tmp/r10earl64_excen64}
SCORE=$(dirname "$0")/score64.py
IN=$1; OUT=$2
STAGE=/tmp/r10earl64_dirscore/$$; mkdir -p "$STAGE"
: > "$OUT"
while read -r view rel <&3; do
  [ "$view" = plain ] || continue
  src="$ROOT/$rel"
  key=$(echo "$rel" | tr '/' '_')
  d="$STAGE/$key"; mkdir -p "$d"; cp "$src"/*.sv "$d/" 2>/dev/null || continue
  ( cd "$d" && "$SL" -parse -nobuiltin -nocache -d uhdm *.sv >sl.log 2>&1 </dev/null )
  G="$d/slpp_all/surelog.uhdm"
  [ -f "$G" ] || { echo "$rel SURELOG_FAIL" >> "$OUT"; continue; }
  ( cd "$d" && "$PAT"  --single-unit *.sv -o pat.uhdm  >p.log 2>&1 </dev/null )
  ( cd "$d" && "$PRIS" --single-unit *.sv -o pris.uhdm >o.log 2>&1 </dev/null )
  [ -f "$d/pat.uhdm" ] && [ -f "$d/pris.uhdm" ] || { echo "$rel NO_DB" >> "$OUT"; continue; }
  R64_INST=1 "$CEN" "$G"           | sort > "$d/g.ex"
  R64_INST=1 "$CEN" "$d/pris.uhdm" | sort > "$d/o.ex"
  R64_INST=1 "$CEN" "$d/pat.uhdm"  | sort > "$d/p.ex"
  echo "$rel $(python3 "$SCORE" "$d/g.ex" "$d/o.ex" "$d/p.ex" 5 0 | head -1)" >> "$OUT"
done 3< "$IN"
cat "$OUT"
