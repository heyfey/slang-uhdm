#!/usr/bin/env bash
# r10earl73 WIDE BOUNDARY — every .sv and .v under a COPY of tools/probe at ANY depth,
# both views, both frozen binaries, workdir-normalised dump byte-compare.
# List on fd 3, children </dev/null, PROCESSED asserted.  MEASUREMENT ONLY.
set -u
PAT=${PATCHED_BIN:?}; PRIS=${PRISTINE_BIN:?}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
ROOT=${PROBE_ROOT:?}
STAGE=${STAGE:-/tmp/r10earl73_widest}; mkdir -p "$STAGE"
LIST=$1; OUT=$2
n=0; same=0; diffn=0; noout=0
: > $OUT.diff; : > $OUT.signal; : > $OUT.rc
while read -r f <&3; do
  n=$((n+1))
  rel=${f#$ROOT/}
  key=$(echo "$rel" | tr '/' '_'); key=${key%.sv}; key=${key%.v}
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
      echo "$rc $side $view $rel" >> $OUT.rc
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
echo "PROCESSED=$n identical=$same DIFFERING=$diffn no_output=$noout" > $OUT.tally
awk '{c[$1]++} END {for (k in c) printf "rc=%s %d\n", k, c[k]}' $OUT.rc | sort > $OUT.rc_histogram
