#!/usr/bin/env bash
# r10earl63 — SCORE OF THE WIDE BOUNDARY'S MOVERS, keyed on the OBJECT.
#
# The first version of this script scored the whole path-normalised uhdm-dump as
# a MULTISET OF LINES and reported FIXED == BROKEN on several arms.  That was an
# ARTEFACT, not a measurement: the dump's commonest lines are bare `|vpiParent:`
# and `|vpiOperand:` markers, so a single changed constant shifts the
# MULTIPLICITY of dozens of identical strings and the multiset diff counts each
# shift on both sides.  The instrument here is `pacen63` — one keyed line per
# param_assign carrying only the four fields `constant::Compare` reads — joined
# three ways (golden / pristine / patched) by `score63.py`.
#
#   usage: PATCHED_BIN=.. PRISTINE_BIN=.. PROBE_ROOT=.. armscore63.sh <armlist>
# Arm list is read on fd 3; children run </dev/null.
set -u
export LC_ALL=C
PAT=${PATCHED_BIN:?}; PRIS=${PRISTINE_BIN:?}; ROOT=${PROBE_ROOT:?}
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
PACEN=${PACEN63:-/tmp/r10earl63_pacen63}
SCORE=$(cd "$(dirname "$0")" && pwd)/score63.py
STAGE=/tmp/r10earl63_armscore; rm -rf "$STAGE"; mkdir -p "$STAGE"
arms=0; skipped=0
: > /tmp/r10earl63_armscore.rows
while read -r rel <&3; do
  f="$ROOT/$rel"; [ -f "$f" ] || { skipped=$((skipped+1)); continue; }
  key=$(echo "$rel" | tr '/' '_'); key=${key%.sv}
  d="$STAGE/$key"; mkdir -p "$d"; cp "$f" "$d/"; b=$(basename "$f")
  ( cd "$d" && "$SL" -parse -nobuiltin -nocache -d uhdm "$b" >sl.log 2>&1 </dev/null )
  [ -f "$d/slpp_all/surelog.uhdm" ] || { echo "SKIP_NO_GOLDEN $rel"; skipped=$((skipped+1)); continue; }
  ( cd "$d" && "$PRIS" "$b" -o pris.uhdm >pris.log 2>&1 </dev/null )
  ( cd "$d" && "$PAT"  "$b" -o pat.uhdm  >pat.log  2>&1 </dev/null )
  [ -f "$d/pris.uhdm" ] && [ -f "$d/pat.uhdm" ] || { echo "SKIP_NO_OURS $rel"; skipped=$((skipped+1)); continue; }
  "$PACEN" "$d/slpp_all/surelog.uhdm" | sort > "$d/gold.pa"
  "$PACEN" "$d/pris.uhdm" | sort > "$d/pris.pa"
  "$PACEN" "$d/pat.uhdm"  | sort > "$d/pat.pa"
  arms=$((arms+1))
  python3 "$SCORE" "$d/gold.pa" "$d/pris.pa" "$d/pat.pa" "$rel" >> /tmp/r10earl63_armscore.rows
done 3< "${1:?arm list}"
echo "ARMS=$arms SKIPPED=$skipped"
grep TOTALS /tmp/r10earl63_armscore.rows
echo "--- aggregate ---"
grep TOTALS /tmp/r10earl63_armscore.rows |
  sed "s/.*TOTALS //" | tr -d "{}'" | tr ',' '\n' |
  awk -F': ' '{gsub(/ /,"",$1); s[$1]+=$2} END {for (k in s) printf "  %-14s %d\n", k, s[k]}'
