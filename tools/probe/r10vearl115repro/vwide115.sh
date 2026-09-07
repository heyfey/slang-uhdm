#!/usr/bin/env bash
# r10vearl115 -- THE TOP-AWARE WIDE BOUNDARY.  MEASUREMENT ONLY.
#
# WHY IT EXISTS: r10earl115's `wide115.sh` runs every arm file with NO `-top`.
# An arm whose file holds several modules therefore elaborates whatever slang
# picks, not the design the arm was written to test -- and r10vearl114's four
# arms fall exactly in that hole: with no `-top` they compare IDENTICAL and are
# absent from `BOUNDARY_WIDE.diff`, while with their OWN `-top` (out of their
# own committed `TOPS.txt`) two of them move under r10earl115's OWN scorer.
#
# This driver reads every `TOPS.txt` committed under tools/probe and re-runs the
# arm it names with that top, both views, both frozen binaries, workdir-
# normalised dump byte-compare.  List on fd 3, children </dev/null, PROCESSED
# asserted against LISTED, one rc line per invocation.
#
#   PATCHED_BIN=<bin> PRISTINE_BIN=<bin> PROBE_ROOT=<tools/probe> \
#     bash vwide115.sh <listfile> <outprefix>
set -u
PAT=${PATCHED_BIN:?}; PRIS=${PRISTINE_BIN:?}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
ROOT=${PROBE_ROOT:?}
STAGE=${STAGE:-/tmp/vearl115_vwide}; mkdir -p "$STAGE"
LIST=$1; OUT=$2
n=0; same=0; diffn=0; noout=0
: > $OUT.diff; : > $OUT.rc; : > $OUT.signal
while read -r rel top <&3; do
  [ -n "${rel:-}" ] || continue
  f="$ROOT/$rel"
  [ -f "$f" ] || { echo "MISSING $rel" >> $OUT.signal; continue; }
  n=$((n+1))
  key=$(echo "$rel" | tr '/' '_'); key=${key%.sv}; key=${key%.v}
  for view in plain elab; do
    case $view in plain) FLAGS="";; elab) FLAGS="--elabuhdm";; esac
    ok=1
    for side in A B; do
      case $side in A) BIN=$PAT;; B) BIN=$PRIS;; esac
      d="$STAGE/${key}_${view}_$side"; mkdir -p "$d"
      # COMPILE IN PLACE, never from a staged copy: r10vearl114's arms
      # `\`include` a sibling package file, and a copied single file drops
      # them into `no_output` on BOTH binaries -- which is exactly how they
      # went unscored.  The output goes to this side's scratch dir.
      b=$(basename "$f"); fd=$(dirname "$f")
      ( cd "$fd" && "$BIN" $FLAGS --top "$top" "$b" --nobuiltin -o "$d/slang.uhdm" >"$d/slang.log" 2>&1 </dev/null )
      rc=$?
      echo "$rc $side $view $rel" >> $OUT.rc
      [ "$rc" -gt 128 ] && echo "SIGNAL rc=$rc $side $view $rel" >> $OUT.signal
      [ -f "$d/slang.uhdm" ] || { ok=0; continue; }
      "$DUMP" "$d/slang.uhdm" 2>/dev/null | sed '1d' |
        sed "s#${key}_${view}_$side#WD#g; s#$STAGE#STG#g" > "$d/o.norm"
      [ -s "$d/o.norm" ] || ok=0
    done
    if [ "$ok" = 0 ]; then
      noout=$((noout+1))
      rm -rf "$STAGE/${key}_${view}_A" "$STAGE/${key}_${view}_B"; continue
    fi
    if cmp -s "$STAGE/${key}_${view}_A/o.norm" "$STAGE/${key}_${view}_B/o.norm"; then
      same=$((same+1)); rm -rf "$STAGE/${key}_${view}_A" "$STAGE/${key}_${view}_B"
    else
      diffn=$((diffn+1)); echo "$view $rel top=$top" >> $OUT.diff
    fi
  done
done 3< "$LIST"
echo "LISTED=$(grep -c . "$LIST") PROCESSED=$n identical=$same DIFFERING=$diffn no_output=$noout" > $OUT.tally
awk '{c[$1" "$2]++} END {for (k in c) printf "rc=%s %d\n", k, c[k]}' $OUT.rc | sort > $OUT.rc_by_side
