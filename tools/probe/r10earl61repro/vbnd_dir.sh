#!/usr/bin/env bash
# r10v61 VERIFIER -- RESULT: PROCESSED dirs=1088 runs=4352 DIFFERING=0,
# NOOUT=232, SIGNALS=8 SYMMETRIC (4/4).  This is the companion the per-FILE
# boundary needs: 255 single-file arms produce no database alone (a `top_*.sv`
# that needs its siblings) and are therefore INVISIBLE to a per-file sweep.
# r10v61 VERIFIER DIRECTORY BOUNDARY — every tools/probe DIRECTORY that holds
# .sv files is compiled as ONE multi-file design (--single-unit), both views,
# both binaries.  This covers the 255 single-file arms that produce no database
# on their own (a `top_*.sv` that needs its siblings).
set -u
PAT=${1:?}; PRIS=${2:?}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
ROOT=${PROBE_ROOT:-/tmp/wt_v61/tools/probe}
STAGE=/tmp/v61_bnddir; rm -rf "$STAGE"; mkdir -p "$STAGE"
LIST=/tmp/v61_bnddir_list.txt
find "$ROOT" -name '*.sv' -printf '%h\n' | LC_ALL=C sort -u > "$LIST"
exec 3< "$LIST"
n=0
: > /tmp/v61_bnddir_diff.list; : > /tmp/v61_bnddir_noout.list; : > /tmp/v61_bnddir_signal.list
while IFS= read -r dir <&3; do
  n=$((n+1))
  rel=${dir#$ROOT/}; key=$(echo "$rel" | tr '/' '_')
  for view in plain elab; do
    case $view in plain) FLAGS="";; elab) FLAGS="--elabuhdm";; esac
    ok=1
    for side in A B; do
      case $side in A) BIN=$PAT;; B) BIN=$PRIS;; esac
      d="$STAGE/${key}_${view}_$side"; mkdir -p "$d"
      cp "$dir"/*.sv "$d/" 2>/dev/null || { ok=0; continue; }
      ( cd "$d" && timeout 180 "$BIN" $FLAGS --single-unit *.sv -o slang.uhdm >slang.log 2>&1 </dev/null )
      rc=$?
      [ "$rc" -gt 128 ] && echo "SIGNAL rc=$rc $side $view $rel" >> /tmp/v61_bnddir_signal.list
      [ -f "$d/slang.uhdm" ] || { ok=0; continue; }
      "$DUMP" "$d/slang.uhdm" 2>/dev/null | sed '1d' \
        | sed "s#${key}_${view}_$side#WD#g" > "$d/o.norm"
      [ -s "$d/o.norm" ] || ok=0
    done
    if [ "$ok" = 0 ]; then echo "$view $rel" >> /tmp/v61_bnddir_noout.list
      rm -rf "$STAGE/${key}_${view}_A" "$STAGE/${key}_${view}_B"; continue; fi
    if cmp -s "$STAGE/${key}_${view}_A/o.norm" "$STAGE/${key}_${view}_B/o.norm"; then
      rm -rf "$STAGE/${key}_${view}_A" "$STAGE/${key}_${view}_B"
    else echo "$view $rel" >> /tmp/v61_bnddir_diff.list; fi
  done
done
echo "PROCESSED dirs=$n (list=$(wc -l < $LIST)) runs=$((n*4))"
echo "DIFFERING=$(grep -c . /tmp/v61_bnddir_diff.list; true) NOOUT=$(grep -c . /tmp/v61_bnddir_noout.list; true) SIGNALS=$(grep -c . /tmp/v61_bnddir_signal.list; true)"
echo "--- differing"; cat /tmp/v61_bnddir_diff.list
echo "signal sides: A(patched)=$(grep -c ' A ' /tmp/v61_bnddir_signal.list; true) B(pristine)=$(grep -c ' B ' /tmp/v61_bnddir_signal.list; true)"
