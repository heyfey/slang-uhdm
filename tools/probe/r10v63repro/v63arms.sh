#!/usr/bin/env bash
# r10v63 VERIFIER — score every boundary mover AGAINST GOLDEN with the
# verifier's OWN 3-way object-keyed scorer (v63score.py + v63field.py).
# Arm list on fd 3; children </dev/null; PROCESSED asserted.
set -u
export LC_ALL=C
PAT=/tmp/v63_bin/pat; PRIS=/tmp/v63_bin/pris; PACEN=/tmp/v63_bin/pacen63
SL=$HOME/git-repos/Surelog/build/bin/surelog
ROOT=${PROBE_ROOT:?}; MODE=${MODE:-file}
STAGE=${STAGE:?}; mkdir -p "$STAGE"
n=0; scored=0; skipped=0
: > $STAGE/rows; : > $STAGE/fields
while read -r rel <&3; do
  n=$((n+1))
  key=$(echo "$rel" | tr '/' '_'); key=${key%.sv}
  d="$STAGE/$key"; mkdir -p "$d"
  if [ "$MODE" = dir ]; then
    cp "$ROOT/$rel"/*.sv "$d/" 2>/dev/null || { skipped=$((skipped+1)); continue; }
    SRC="--single-unit *.sv"; GSRC="-parse -nobuiltin -nocache -d uhdm *.sv"
  else
    [ -f "$ROOT/$rel" ] || { skipped=$((skipped+1)); continue; }
    cp "$ROOT/$rel" "$d/"; b=$(basename "$rel")
    SRC="$b"; GSRC="-parse -nobuiltin -nocache -d uhdm $b"
  fi
  ( cd "$d" && eval "$SL" $GSRC >sl.log 2>&1 </dev/null )
  [ -f "$d/slpp_all/surelog.uhdm" ] || { echo "SKIP_NO_GOLDEN $rel" >> $STAGE/skips; skipped=$((skipped+1)); continue; }
  ( cd "$d" && eval "$PRIS" $SRC -o pris.uhdm >pris.log 2>&1 </dev/null )
  ( cd "$d" && eval "$PAT"  $SRC -o pat.uhdm  >pat.log  2>&1 </dev/null )
  [ -f "$d/pris.uhdm" ] && [ -f "$d/pat.uhdm" ] || { echo "SKIP_NO_OURS $rel" >> $STAGE/skips; skipped=$((skipped+1)); continue; }
  "$PACEN" "$d/slpp_all/surelog.uhdm" | sort > "$d/gold.pa"
  "$PACEN" "$d/pris.uhdm" | sort > "$d/pris.pa"
  "$PACEN" "$d/pat.uhdm"  | sort > "$d/pat.pa"
  scored=$((scored+1))
  python3 /tmp/v63_scratch/v63score.py "$d/gold.pa" "$d/pris.pa" "$d/pat.pa" "$rel" >> $STAGE/rows
  python3 /tmp/v63_scratch/v63field.py "$d/gold.pa" "$d/pris.pa" "$d/pat.pa" "$rel" >> $STAGE/fields
done 3< "${1:?arm list}"
echo "PROCESSED=$n SCORED=$scored SKIPPED=$skipped"
