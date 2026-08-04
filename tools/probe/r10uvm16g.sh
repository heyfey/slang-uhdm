#!/bin/bash
# r10uvm16g.sh <Test> — print the golden .uhdm path for a UVM-4 test from the
# pass-16 sweep workdir (R10W).
set -u
T=$1
SW=${R10W:-/tmp/r10uvm16_u4w}
D=$(ls -d $SW/default/$T-* 2>/dev/null | head -1)
grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' "$D/cmds.txt" | head -1 | sed 's#$#/golden.uhdm#'
