#!/usr/bin/env bash
# r10earl110 -- THE MOVER PREDICTION, made from PRISTINE databases ONLY and
# BEFORE the patched sweep runs.  MEASUREMENT ONLY.
#
# § hpSelHalfOpParamFold110 can only rewrite a hier_path NAME whose bracket
# group holds an ARITHMETIC half that still carries an IDENTIFIER.  This driver
# censuses every pristine database in a verify_golden workdir with cen110 and
# prints the row-databases that contain at least one such name -- a deliberate
# OVER-prediction (it ignores the depth-1 generate-scope gate and the
# localparam/package symbol test), so the actual mover set must be a SUBSET of
# what it names.  A database that fails to census is printed as CENFAIL and
# counted; a driver that reaches nothing must never read as "no movers".
set -u
WD=${1:?workdir}; OUT=${2:?outfile}
HERE=$(cd "$(dirname "$0")" && pwd)
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
: > "$OUT"
n=0; hit=0; fail=0
while IFS= read -r db; do
  n=$((n+1))
  d=$(dirname "$db"); tag=$(basename "$(dirname "$d")")/$(basename "$d")
  if ! "$HERE/cen110" "$db" 2>/dev/null | grep -q '^CENRC 0$'; then
    echo "CENFAIL $tag" >> "$OUT"; fail=$((fail+1)); continue
  fi
  m=$("$HERE/cen110" "$db" 2>/dev/null |
      grep -P '\[[^]\[]*[A-Za-z_][A-Za-z0-9_]*[^]\[]*[-+*/][^]\[]*\]' | grep -c '' ; true)
  if [ "${m:-0}" -gt 0 ]; then
    echo "CAND $tag $m" >> "$OUT"; hit=$((hit+1))
  fi
done < <(find "$WD" -name slang.uhdm | sort)
echo "-- scanned=$n CAND=$hit CENFAIL=$fail" | tee -a "$OUT"
