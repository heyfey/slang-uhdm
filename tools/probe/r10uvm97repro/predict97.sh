#!/usr/bin/env bash
# r10uvm97 — run pred97 over a whole verify_golden workdir of OUR PRISTINE
# databases and name every (mode, test) that carries the shape the patch
# removes.  MEASUREMENT ONLY; run BEFORE the patched sweep is looked at.
#   ./predict97.sh <pristine-workdir> [outfile]
set -u
WD=${1:?workdir}; OUT=${2:-/dev/stdout}
P=${PRED:-/tmp/r10uvm97_pred97}
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib:${LD_LIBRARY_PATH:-}
n=0; tot=0
{
for d in "$WD"/*/*/; do
  mode=$(basename "$(dirname "$d")"); test=$(basename "$d")
  O="$d/slang.uhdm"; [ -f "$O" ] || continue
  tot=$((tot+1))
  c=$("$P" "$O" 2>/dev/null | sed -n 's/^COUNT //p')
  [ -z "$c" ] && c=0
  if [ "$c" != 0 ]; then echo "PREDICT $mode/$test  cells=$c"; n=$((n+1)); fi
done
echo "PREDICTED $n / $tot databases"
} > "$OUT"
