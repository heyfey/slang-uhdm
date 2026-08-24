#!/usr/bin/env bash
# v82 verifier WIDE BOUNDARY — every .sv AND .v under a COPY of tools/probe at
# ANY depth, BOTH views, both frozen binaries, workdir-normalised dump compare.
# List on fd 3, children </dev/null, PROCESSED asserted, rc recorded per cell.
set -u
A_BIN=${A_BIN:?}; B_BIN=${B_BIN:?}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
ROOT=${PROBE_ROOT:?}
LIST=$1; OUT=$2; STAGE=$3
mkdir -p "$STAGE"
n=0; same=0; diffn=0; noout=0
: > $OUT.diff; : > $OUT.signal; : > $OUT.rc
while read -r rel <&3; do
  n=$((n+1))
  key=$(echo "$rel" | tr '/' '_')
  for view in plain elab; do
    case $view in plain) FLAGS="";; elab) FLAGS="--elabuhdm";; esac
    ok=1
    for side in A B; do
      case $side in A) BIN=$A_BIN;; B) BIN=$B_BIN;; esac
      d="$STAGE/${key}_${view}_$side"; mkdir -p "$d"
      cp "$ROOT/$rel" "$d/" 2>/dev/null || { ok=0; continue; }
      b=$(basename "$rel")
      ( cd "$d" && "$BIN" $FLAGS "$b" -o slang.uhdm >slang.log 2>&1 </dev/null )
      rc=$?
      echo "$rel $view $side rc=$rc" >> $OUT.rc
      [ "$rc" -gt 128 ] && echo "SIGNAL rc=$rc $side $view $rel" >> $OUT.signal
      [ -f "$d/slang.uhdm" ] || { ok=0; continue; }
      "$DUMP" "$d/slang.uhdm" 2>/dev/null | sed '1d' \
        | sed "s#${key}_${view}_$side#WD#g; s#$STAGE#STG#g" > "$d/o.norm"
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
