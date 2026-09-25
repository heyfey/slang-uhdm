#!/bin/bash
# ds.sh <bin> <outfile> <case dirs...> : downstream verdict per case (fresh GOLDEN_CACHE, fence-guarded)
source "$(dirname "$0")/env.sh"  # FENCED must come from the caller's environment
b=$1; out=$2; shift 2; tag=$(basename $b .bin)${VCTAG:+_$VCTAG}
export SLANG_UHDM=$b GOLDEN_CACHE=/tmp/v11u154_dsgc
: > $out
for d in "$@"; do d=$(cd $d && pwd); [ -n "$FENCED" ] || { echo "FENCED unset: refusing"; exit 2; }; for f in $FENCED; do case "$d" in *"$f"*) continue 2;; esac; done
  n=$(basename $(dirname $d))_$(basename $d)
  (cd /tmp/wt_v11u154 && python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; r=ds.one('$n', '$d', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '/tmp/v11u154_dsw/$tag', 300); print(r['name'], r['verdict'], r['differs'], r['surelog_status'], r['slang_status'])") >> $out 2>&1
done
