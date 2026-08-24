#!/usr/bin/env bash
# r10v79 PER-DIRECTORY BOUNDARY — every probe directory holding .sv or .v
# compiled as ONE unit, both views, both frozen binaries.  List on fd 3,
# children </dev/null, PROCESSED asserted, rc recorded per cell.
set -u
PAT=${PATCHED_BIN:?}; PRIS=${PRISTINE_BIN:?}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
ROOT=${PROBE_ROOT:?}
STAGE=${STAGE:-/tmp/v79_dirst}; mkdir -p "$STAGE"
LIST=$1; OUT=$2
n=0; same=0; diffn=0; noout=0
: > $OUT.diff; : > $OUT.signal; : > $OUT.rc
while read -r dir <&3; do
  n=$((n+1))
  rel=${dir#$ROOT/}
  key=$(echo "$rel" | tr '/' '_')
  for view in plain elab; do
    case $view in plain) FLAGS="";; elab) FLAGS="--elabuhdm";; esac
    ok=1
    for side in A B; do
      case $side in A) BIN=$PAT;; B) BIN=$PRIS;; esac
      d="$STAGE/${key}_${view}_$side"; mkdir -p "$d"
      cp "$dir"/*.sv "$d/" 2>/dev/null; cp "$dir"/*.v "$d/" 2>/dev/null
      # NOT `ls a/*.sv a/*.v`: ls returns NON-ZERO when EITHER glob misses, so a
      # directory holding only .sv files was silently skipped -- 32 of 6100
      # cells ran before the PROCESSED assertion caught it.  Count files.
      nf=$(ls "$d"/*.sv "$d"/*.v 2>/dev/null | wc -l)
      [ "$nf" -gt 0 ] || { ok=0; continue; }
      ( cd "$d" && set -- $(ls *.sv *.v 2>/dev/null) && "$BIN" $FLAGS "$@" -o slang.uhdm >slang.log 2>&1 </dev/null )
      rc=$?
      echo "$rel $view $side rc=$rc" >> $OUT.rc
      [ "$rc" -gt 128 ] && echo "SIGNAL rc=$rc $side $view $rel" >> $OUT.signal
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
echo "LISTED=$(wc -l < $LIST) PROCESSED=$n identical=$same DIFFERING=$diffn no_output=$noout" > $OUT.tally
