#!/bin/bash
# (v11u238) ds.sh <casedir> <tag> <binary> [ENV=VAL ...]: the downstream verdict of one case (scripts/downstream_uhdm2rtlil.py
# one(), the Surelog lane with uhdm2rtlil's own Surelog, the slang lane under the given binary and environment). Fail-closed on $FENCED.
[ -n "$FENCED" ] && [ -n "$S" ] || { echo "ds.sh: source drivers/env.sh" >&2; exit 2; }
c=$(realpath $1); t=$2; b=$3; shift 3
[ -x "$b" ] || { echo "ds.sh: binary not executable: $b" >&2; exit 2; }
for n in $FENCED; do echo "$c" | grep -qw "$n" && { echo "ds.sh: fenced path refused" >&2; exit 2; }; done
H=$(cd "$(dirname "$0")/../../../.." && pwd)
w=$S/ds/$(basename $c)_$t; rm -rf $w; mkdir -p $w
env "$@" SLANG_UHDM=$b python3 -c "import sys; sys.path.insert(0,'$H/scripts'); import downstream_uhdm2rtlil as ds; r=ds.one('$(basename $c)', '$c', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$w', 300); print('$(basename $c) $t', r)"
