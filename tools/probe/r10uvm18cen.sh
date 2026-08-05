#!/bin/bash
# r10uvm18cen.sh <Test> <nameFilter> [deep|listing] — the r10uvm18a census over
# ONE UVM-4 pair, golden then ours, side by side.  This is the instrument
# § pkgTdRangeViewFold18 was read off: for every task_func in every VIEW it
# prints each io_decl / return / body-local typespec with its packed-range
# fold state, its vpiInstance and its Typedef_alias target's same triple.
#   deep    — also print the whole left-bound expression with each ref's actual
#   listing — print the package's own Typespecs vector instead of its bodies
set -u
T=$1; F=${2:-}; D3=${3:-}
SW=${R10W:-/tmp/r10uvm18_u4w}
O=${R10O:-/tmp/r10uvm18_m}
A=${R10A:-/tmp/r10uvm18_a}
D=$(ls -d $SW/default/$T-* 2>/dev/null | head -1)
G=$(grep -o "$HOME/.cache/slang-uhdm-goldens/[0-9a-f]*" "$D/cmds.txt" | head -1)/golden.uhdm
echo "=== GOLDEN $G"
$A "$G" "$F" $D3 2>/dev/null
echo "=== OURS"
$A "$O/$T.uhdm" "$F" $D3 2>/dev/null
