#!/usr/bin/env bash
# r10uvm89 — THE MOVER PREDICTOR, run on PRISTINE bytes ONLY.
#
# § hpTrailSelIdxDecompiled89 rewrites the bracket group of a TRAILING component
# select of a hier_path whose index is a kind `decompileHelper` has NO row for.
# ct89cen prints, per hier_path, one `TRAIL:<elem>:IDX=<kinds>:BRK=<text>` field
# per index-carrying element, so the reachable cells are READ OFF THE PRISTINE
# DATABASE, by name, before the patched binary exists:
#
#   a TRAIL bit_select whose IDX kind is NOT constant / ref_obj / operation.
#
# LVAL=1 -> the bracket text becomes `[]`;  LVAL!=1 -> the whole group vanishes.
# A database with ZERO such cells is predicted BYTE-IDENTICAL.
#
#   usage: pred89.sh <workdir-root>   (a verify_golden.py workdir)
set -u
WD=${1:?workdir root}
CEN=${CEN:-/tmp/r10uvm89_ct89cen}
tot=0; hit=0
while read -r p; do
  tot=$((tot+1))
  rows=$("$CEN" "$p" --idx 2>/dev/null |
    grep -oE 'TRAIL:bit_select:IDX=[a-z_]+' |
    grep -vE 'IDX=(constant|ref_obj|operation)$' | sort | uniq -c || true)
  n=$(printf '%s' "$rows" | awk '{s+=$1} END{print s+0}')
  if [ "${n:-0}" -gt 0 ]; then
    hit=$((hit+1))
    echo "PRED_MOVER $n ${p#$WD/}"
    "$CEN" "$p" --idx 2>/dev/null |
      awk -F'\t' '{lv="";nm="";ik="";for(j=1;j<=NF;j++){if($j~/^LVAL=/)lv=substr($j,6);if($j~/^NAME=/)nm=substr($j,6);if($j~/^IDXK=/)ik=substr($j,6)}
                   nsp=split(ik,ps,";"); for(q=1;q<=nsp;q++) if(ps[q]~/^TRAIL:bit_select:IDX=/ && ps[q]!~/IDX=(constant|ref_obj|operation):/)
                     print "    LVAL="lv"  "nm}' | sort -u
  fi
done < <(find "$WD" -name slang.uhdm | sort)
echo "-- databases=$tot  PREDICTED MOVERS=$hit"
