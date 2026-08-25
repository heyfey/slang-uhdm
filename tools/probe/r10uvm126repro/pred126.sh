#!/usr/bin/env bash
# r10uvm126 - A-PRIORI MOVER PREDICTOR / CORPUS CENSUS.
# For every PRISTINE slang.uhdm in a verify_golden workdir it finds the GOLDEN
# from that row's own cmds.txt, runs cen126 on BOTH and scores them with
# score126.py.  A database is a PREDICTED MOVER iff it holds at least one LAW
# cell (golden's unpacked-array element typespec is an ANONYMOUS BUILTIN
# KEYWORD typespec and ours is not).  RESIDUE cells are named/aggregate element
# typespecs this pass deliberately does not touch.
# LHS IS ALWAYS GOLDEN.  MEASUREMENT ONLY - the official uhdm-cmp is the judge.
#   usage: CEN126=.. SCORE126=.. pred126.sh <workdir> [more workdirs...]
set -u
CEN=${CEN126:?set CEN126}
SC=${SCORE126:?set SCORE126}
OUT=${PRED_OUT:-}
tot=0; hit=0; res=0; nog=0
[ -n "$OUT" ] && mkdir -p "$OUT"
for WD in "$@"; do
  while IFS= read -r db; do
    tot=$((tot+1))
    d=$(dirname "$db")
    tag=$(echo "$d" | sed 's#.*/\([^/]*\)/\([^/]*\)$#\1/\2#')
    G=""
    [ -f "$d/cmds.txt" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
    if [ -z "$G" ] || [ ! -f "$G" ]; then nog=$((nog+1)); continue; fi
    gc=$(mktemp /tmp/r10uvm126_pred_g.XXXXXX); oc=$(mktemp /tmp/r10uvm126_pred_o.XXXXXX)
    "$CEN" "$G"  > "$gc" 2>/dev/null
    "$CEN" "$db" > "$oc" 2>/dev/null
    S=$(python3 "$SC" "$gc" "$oc" 2>/dev/null)
    L=$(echo "$S" | awk '$1=="LAW"{print $2}'); L=${L:-0}
    R=$(echo "$S" | awk '$1=="RESIDUE"{print $2}'); R=${R:-0}
    if [ -n "$OUT" ]; then cp "$gc" "$OUT/$(echo "$tag"|tr / _).g.cen"; cp "$oc" "$OUT/$(echo "$tag"|tr / _).o.cen"; fi
    rm -f "$gc" "$oc"
    [ "$R" -gt 0 ] && res=$((res+1))
    if [ "$L" -gt 0 ]; then hit=$((hit+1)); echo "PREDICT law=$L residue=$R $tag"; fi
  done < <(find "$WD" -name 'slang.uhdm' | sort)
done
echo "SCANNED=$tot PREDICTED_MOVERS=$hit WITH_RESIDUE_ONLY_OR_ALSO=$res NO_GOLDEN=$nog"
