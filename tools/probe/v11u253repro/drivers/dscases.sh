#!/bin/bash
# (v11u253) dscases.sh <binary> <tag> <case dir>...: the downstream verdict of each case (scripts/downstream_uhdm2rtlil.py
# one()) with SLANG_UHDM=<binary>, one line per case. Fail-closed on $FENCED; paths filtered first.
[ -n "$FENCED" ] && [ -n "$S" ] || { echo "dscases.sh: source drivers/env.sh" >&2; exit 2; }
b=$1; t=$2; shift 2; [ -x "$b" ] || { echo "dscases.sh: binary not executable" >&2; exit 2; }
REPO=$(cd "$(dirname "$0")/../../../.." && pwd)
for c in $(printf '%s\n' "$@" | grep -vwE "$FENCE_RE"); do
  c=$(realpath $c); n=$(basename $c); w=$S/ds_$t/$n; rm -rf $w; mkdir -p $w
  ( cd $REPO && SLANG_UHDM=$b python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; print(ds.one('$n', '$c', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$w', 300))" 2>&1 | tail -1 | sed "s#^#$t $n #" )
done
