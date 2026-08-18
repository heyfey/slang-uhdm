#!/usr/bin/env bash
# v65 VERIFIER WIDE BOUNDARY — every .sv under a COPY of tools/probe at ANY
# depth, BOTH views, both frozen binaries, workdir-normalised dump compare.
# List on fd 3, children </dev/null, PROCESSED asserted, rc recorded PER CELL.
set -u
PAT=${PATCHED_BIN:?}; PRIS=${PRISTINE_BIN:?}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
ROOT=${PROBE_ROOT:?}; STAGE=${STAGE:?}
LIST=$1; OUT=$2
mkdir -p "$STAGE"
n=0; same=0; diffn=0; noout=0
: > $OUT.diff; : > $OUT.rc
while read -r f <&3; do
  n=$((n+1)); rel=${f#$ROOT/}
  key=$(echo "$rel" | tr '/' '_'); key=${key%.sv}
  for view in plain elab; do
    case $view in plain) FLAGS="";; elab) FLAGS="--elabuhdm";; esac
    ok=1
    for side in A B; do
      case $side in A) BIN=$PAT;; B) BIN=$PRIS;; esac
      d="$STAGE/${key}_${view}_$side"; mkdir -p "$d"
      cp "$f" "$d/" 2>/dev/null || { ok=0; continue; }
      b=$(basename "$f")
      ( cd "$d" && "$BIN" $FLAGS "$b" -o slang.uhdm >slang.log 2>&1 </dev/null )
      rc=$?
      echo "$rel $view $side rc=$rc" >> $OUT.rc
      [ -f "$d/slang.uhdm" ] || { ok=0; continue; }
      "$DUMP" "$d/slang.uhdm" 2>/dev/null | sed '1d' | sed "s#${key}_${view}_$side#WD#g; s#$STAGE#STG#g" > "$d/o.norm"
      [ -s "$d/o.norm" ] || ok=0
    done
    if [ "$ok" = 0 ]; then noout=$((noout+1)); rm -rf "$STAGE/${key}_${view}_A" "$STAGE/${key}_${view}_B"; continue; fi
    if cmp -s "$STAGE/${key}_${view}_A/o.norm" "$STAGE/${key}_${view}_B/o.norm"; then
      same=$((same+1)); rm -rf "$STAGE/${key}_${view}_A" "$STAGE/${key}_${view}_B"
    else
      diffn=$((diffn+1)); echo "$view $rel" >> $OUT.diff
    fi
  done
done 3< "$LIST"
echo "PROCESSED=$n LISTED=$(wc -l < $LIST) identical=$same DIFFERING=$diffn no_output=$noout" > $OUT.tally
