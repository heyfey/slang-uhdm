#!/bin/bash
# vds404.sh <binary> <workroot> <case-glob...> : downstream verdict per case (scripts/downstream_uhdm2rtlil.py one()).
B=$1; W=$2; shift 2
HERE=$(cd "$(dirname "$0")/.." && pwd); REPO=$(cd "$HERE/../../.." && pwd)
for g in "$@"; do for d in $(cd $HERE/cases && ls -d $g | sort); do
  grep -qE '^\s*(class|program)\b|process|mailbox|semaphore' $HERE/cases/$d/dut.sv && { echo "$d SKIP-class"; continue; }
  (cd $REPO && SLANG_UHDM=$B python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; r=ds.one('${d//\//_}', '$HERE/cases/$d', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$W', 300); print('$d', r['verdict'], r['differs'], r['surelog_status'], r['slang_status'], r['detail'][:60])")
done; done
