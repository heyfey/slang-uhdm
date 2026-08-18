#!/usr/bin/env bash
# r10earl63 — same keyed score as armscore63.sh, for the MULTI-FILE (per
# directory, --single-unit) boundary movers.  List on fd 3, children </dev/null.
set -u
export LC_ALL=C
PAT=${PATCHED_BIN:?}; PRIS=${PRISTINE_BIN:?}; ROOT=${PROBE_ROOT:?}
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
PACEN=${PACEN63:-/tmp/r10earl63_pacen63}
SCORE=$(cd "$(dirname "$0")" && pwd)/score63.py
STAGE=/tmp/r10earl63_dirscore; rm -rf "$STAGE"; mkdir -p "$STAGE"
: > /tmp/r10earl63_dirscore.rows
n=0; skipped=0
while read -r rel <&3; do
  d0="$ROOT/$rel"; [ -d "$d0" ] || { skipped=$((skipped+1)); continue; }
  key=$(echo "$rel" | tr '/' '_'); d="$STAGE/$key"; mkdir -p "$d"
  cp "$d0"/*.sv "$d/" 2>/dev/null || { skipped=$((skipped+1)); continue; }
  ( cd "$d" && "$SL" -parse -nobuiltin -nocache -d uhdm *.sv >sl.log 2>&1 </dev/null )
  [ -f "$d/slpp_all/surelog.uhdm" ] || { echo "SKIP_NO_GOLDEN $rel"; skipped=$((skipped+1)); continue; }
  ( cd "$d" && "$PRIS" --single-unit *.sv -o pris.uhdm >pris.log 2>&1 </dev/null )
  ( cd "$d" && "$PAT"  --single-unit *.sv -o pat.uhdm  >pat.log  2>&1 </dev/null )
  [ -f "$d/pris.uhdm" ] && [ -f "$d/pat.uhdm" ] || { echo "SKIP_NO_OURS $rel"; skipped=$((skipped+1)); continue; }
  "$PACEN" "$d/slpp_all/surelog.uhdm" | sort > "$d/gold.pa"
  "$PACEN" "$d/pris.uhdm" | sort > "$d/pris.pa"
  "$PACEN" "$d/pat.uhdm"  | sort > "$d/pat.pa"
  n=$((n+1))
  python3 "$SCORE" "$d/gold.pa" "$d/pris.pa" "$d/pat.pa" "$rel" >> /tmp/r10earl63_dirscore.rows
done 3< "${1:?dir list}"
echo "DIRS=$n SKIPPED=$skipped"
grep TOTALS /tmp/r10earl63_dirscore.rows
echo "--- aggregate ---"
grep TOTALS /tmp/r10earl63_dirscore.rows | sed "s/.*TOTALS //" | tr -d "{}'" | tr ',' '\n' |
  awk -F': ' '{gsub(/ /,"",$1); s[$1]+=$2} END {for (k in s) printf "  %-14s %d\n", k, s[k]}'
