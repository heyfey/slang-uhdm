#!/usr/bin/env bash
# r10v61 VERIFIER -- RESULT: PROCESSED arms=2536 (list=2536) runs=10144,
# DIFFERING=16 (8 distinct arms x 2 views), NOOUT=255, SIGNALS=14 SYMMETRIC
# (A(patched)=7 B(pristine)=7).  vbndall61.sh's `$ROOT/*/*.sv` glob reaches only
# the 1 061 DEPTH-1 arms; 1 473 arms live one or two levels deeper and this
# walk reaches all of them.  The 8 differing arms are g1/g2/g3/b1 (this pass's
# witnesses) + a2_earl54, v13_v54, qq, ug -- all attributed, AWAY-GOLDEN 0.
# r10v61 VERIFIER WIDE BOUNDARY — RECURSIVE over tools/probe (all depths),
# both views, both binaries, o.dump byte-compared after workdir normalisation.
#   usage: vbnd_rec.sh <patched> <pristine> <listfile-on-fd3>
set -u
PAT=${1:?}; PRIS=${2:?}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
ROOT=${PROBE_ROOT:-/tmp/wt_v61/tools/probe}
STAGE=/tmp/v61_bndall; rm -rf "$STAGE"; mkdir -p "$STAGE"
LIST=/tmp/v61_bnd_list.txt
# fd 3: the arm list, asserted BEFORE any run
find "$ROOT" -name '*.sv' -type f | LC_ALL=C sort > "$LIST"
exec 3< "$LIST"
n=0
: > /tmp/v61_bnd_diff.list; : > /tmp/v61_bnd_signal.list; : > /tmp/v61_bnd_noout.list
while IFS= read -r f <&3; do
  n=$((n+1))
  rel=${f#$ROOT/}
  key=$(echo "$rel" | tr '/' '_'); key=${key%.sv}
  for view in plain elab; do
    case $view in plain) FLAGS="";; elab) FLAGS="--elabuhdm";; esac
    ok=1
    for side in A B; do
      case $side in A) BIN=$PAT;; B) BIN=$PRIS;; esac
      d="$STAGE/${key}_${view}_$side"; mkdir -p "$d"
      cp "$f" "$d/" 2>/dev/null || { ok=0; continue; }
      b=$(basename "$f")
      ( cd "$d" && timeout 120 "$BIN" $FLAGS "$b" -o slang.uhdm >slang.log 2>&1 </dev/null )
      rc=$?
      [ "$rc" -gt 128 ] && echo "SIGNAL rc=$rc $side $view $rel" >> /tmp/v61_bnd_signal.list
      [ -f "$d/slang.uhdm" ] || { ok=0; continue; }
      "$DUMP" "$d/slang.uhdm" 2>/dev/null | sed '1d' \
        | sed "s#${key}_${view}_$side#WD#g" > "$d/o.norm"
      [ -s "$d/o.norm" ] || ok=0
    done
    if [ "$ok" = 0 ]; then
      echo "$view $rel" >> /tmp/v61_bnd_noout.list
      rm -rf "$STAGE/${key}_${view}_A" "$STAGE/${key}_${view}_B"; continue
    fi
    if cmp -s "$STAGE/${key}_${view}_A/o.norm" "$STAGE/${key}_${view}_B/o.norm"; then
      rm -rf "$STAGE/${key}_${view}_A" "$STAGE/${key}_${view}_B"
    else
      echo "$view $rel" >> /tmp/v61_bnd_diff.list
    fi
  done
done
echo "PROCESSED arms=$n (list=$(wc -l < $LIST)) runs=$((n*4))"
echo "DIFFERING=$(grep -c . /tmp/v61_bnd_diff.list; true) NOOUT=$(grep -c . /tmp/v61_bnd_noout.list; true) SIGNALS=$(grep -c . /tmp/v61_bnd_signal.list; true)"
echo "--- differing (view rel)"; cat /tmp/v61_bnd_diff.list
echo "--- signals"; cat /tmp/v61_bnd_signal.list
echo "signal sides: A(patched)=$(grep -c ' A ' /tmp/v61_bnd_signal.list; true) B(pristine)=$(grep -c ' B ' /tmp/v61_bnd_signal.list; true)"
