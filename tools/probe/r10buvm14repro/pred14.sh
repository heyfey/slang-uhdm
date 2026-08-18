#!/usr/bin/env bash
# r10buvm14 — THE MOVER PREDICTOR, read off PRISTINE BYTES ONLY, before the
# patched binary is allowed to speak.
#
#   usage: pred14.sh <pristine workdir root>   > predictions
#
# THE PRISTINE SIGNATURE of § builtinRecvMultiDimStepIsBitSelectChain14: a
# hier_path whose LAST path element is a `method_func_call` (mc=1) and one of
# whose EARLIER elements is a FLAT `ref_obj` whose name is
# `<ident>[…][…]` — a base name followed by TWO OR MORE non-nested bracket
# groups tiling the rest, which is exactly `stepIdxGroups14`'s text gate with
# N>=2.  That flat ref_obj is what uvm74's `pendMulti` refusal left behind.
#
# THIS IS AN UPPER BOUND AND SAYS SO: the emitter also requires the BOUND TREE
# to confirm the same dimension count, which bytes cannot show.  A predicted
# database that does NOT move is therefore a legitimate outcome (the tree
# refused); a database that MOVES WITHOUT BEING PREDICTED is a defect in the
# law, and that is the direction this control exists to catch.
set -u
W=${1:?pristine workdir root}
CEN=${CEN:-/tmp/r10buvm14cen}
[ -x "$CEN" ] || { echo "FATAL: no census tool at $CEN"; exit 3; }
n=0; hit=0
while read -r db; do
  n=$((n+1))
  c=$("$CEN" "$db" P 2>/dev/null |
      grep ' mc=1 ' |
      grep -cP 'ref_obj\([A-Za-z_$][A-Za-z0-9_$]*(\[[^][]+\]){2,}\)' || true)
  if [ "${c:-0}" -gt 0 ]; then
    echo "PREDICT $c $db"
    hit=$((hit+1))
  fi
done < <(find "$W" -name slang.uhdm | sort)
echo "-- databases scanned=$n  PREDICTED MOVERS (upper bound)=$hit"
