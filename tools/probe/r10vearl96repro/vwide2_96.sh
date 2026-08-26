#!/usr/bin/env bash
# r10v96 WIDE BOUNDARY, TWO INSTRUMENTS.  For every .sv/.v under a probe tree,
# both views, both frozen binaries: (1) the workdir-normalised uhdm-dump byte
# compare and (2) the ct96cen TYPESPEC CENSUS compare -- the dump ABBREVIATES
# an already-visited typespec, so an alias TARGET's name is invisible to a dump
# diff while typespec::Compare reads it; the census is the instrument that sees
# this law's family.  List on fd 3, children </dev/null, PROCESSED asserted,
# every rc recorded.  MEASUREMENT ONLY.
#   usage: vwide2_96.sh <filelist> <out-prefix>
#   env:   PATCHED_BIN PRISTINE_BIN PROBE_ROOT CEN96 [STAGE]
set -u
PAT=${PATCHED_BIN:?}; PRIS=${PRISTINE_BIN:?}; CEN=${CEN96:?}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
ROOT=${PROBE_ROOT:?}
STAGE=${STAGE:-/tmp/v96_widest}; mkdir -p "$STAGE"
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
LIST=$1; OUT=$2
n=0; same=0; diffn=0; noout=0; censame=0; cendiff=0
: > $OUT.diff; : > $OUT.cendiff; : > $OUT.signal; : > $OUT.rc
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
      "$CEN" "$d/slang.uhdm" </dev/null 2>/dev/null | sed "s#${key}_${view}_$side#WD#g" > "$d/o.cen"
      [ -s "$d/o.norm" ] || ok=0
    done
    if [ "$ok" = 0 ]; then noout=$((noout+1)); rm -rf "$STAGE/${key}_${view}_A" "$STAGE/${key}_${view}_B"; continue; fi
    dd=0
    cmp -s "$STAGE/${key}_${view}_A/o.norm" "$STAGE/${key}_${view}_B/o.norm" || { dd=1; echo "$view $rel" >> $OUT.diff; }
    cd2=0
    cmp -s "$STAGE/${key}_${view}_A/o.cen" "$STAGE/${key}_${view}_B/o.cen" || { cd2=1; echo "$view $rel" >> $OUT.cendiff; }
    [ $dd = 0 ] && same=$((same+1)) || diffn=$((diffn+1))
    [ $cd2 = 0 ] && censame=$((censame+1)) || cendiff=$((cendiff+1))
    if [ $dd = 0 ] && [ $cd2 = 0 ]; then rm -rf "$STAGE/${key}_${view}_A" "$STAGE/${key}_${view}_B"; fi
  done
done 3< "$LIST"
echo "PROCESSED=$n dump_identical=$same dump_DIFFERING=$diffn cen_identical=$censame cen_DIFFERING=$cendiff no_output=$noout" > $OUT.tally
awk '{c[$1]++} END {for (k in c) printf "rc=%s %d\n", k, c[k]}' $OUT.rc | sort > $OUT.rc_histogram
awk '{c[$2" "$1]++} END {for (k in c) printf "%s %d\n", k, c[k]}' $OUT.rc | sort > $OUT.rc_by_side
