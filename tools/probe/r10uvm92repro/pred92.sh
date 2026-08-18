#!/usr/bin/env bash
# r10uvm92 — THE MOVER PREDICTOR, run on PRISTINE bytes ONLY, no golden read.
#
# § hpIdxOpPrettyPrint92 rewrites the bracket text of a hier_path NAME whose
# select index is a UHDM OPERATION so that it equals Surelog's
# `decompileHelper` (first dispatch) composed with `ExprEval::prettyPrint`
# (second dispatch).  `ct92cen` computes that composition on the database's OWN
# tree and prints EXPM=Y when the name already agrees with it.  So:
#
#   a database MOVES  <=>  it has at least one EXPM=N cell,
#   and the number of moved NAMES is the number of EXPM=N hier_paths.
#
# This is an INTRINSIC predicate -- it needs no golden and no patched binary --
# so it is a real prediction, made before the patched binary exists.
#   usage: pred92.sh <workdir-root>   (a verify_golden.py workdir)
set -u
WD=${1:?workdir root}
CEN=${CEN:-/tmp/r10uvm92_ct92cen}
tot=0; hit=0; cells=0
while read -r p; do
  tot=$((tot+1))
  n=$("$CEN" "$p" --op 2>&1 >/dev/null | sed -n 's/.*EXPM_N=\([0-9]*\).*/\1/p')
  n=${n:-0}
  if [ "$n" -gt 0 ]; then
    hit=$((hit+1)); cells=$((cells+n))
    echo "PRED_MOVER cells=$n ${p#$WD/}"
    "$CEN" "$p" --op 2>/dev/null | grep -o 'NAME=[^	]*' | sort | uniq -c |
      sed 's/^/      /'
  fi
done < <(find "$WD" -name slang.uhdm | sort)
echo "-- databases=$tot  PREDICTED MOVERS=$hit  moved cells=$cells"
