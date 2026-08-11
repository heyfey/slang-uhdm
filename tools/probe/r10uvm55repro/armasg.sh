#!/bin/bash
# r10uvm55repro/armasg.sh — the ARM cell table for the `new()`-RHS law: every
# assignment and every method_func_call in BOTH sides of a gold.sh outdir,
# sorted, side by side.
#
# LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.
#
#   usage: armasg.sh <gold.sh-outdir>
#
# GUARDS: both databases existence-checked (exit 6, because uhdm-cmp and a naive
# probe both exit 0 on a missing input); asgat's exit 4 (`UNMEASURED`) is
# reported per side and propagated.
set -u
D=${1:?gold.sh outdir}
P=${ASGAT:-/tmp/r10uvm55_asgat}
[ -x "$P" ] || { echo "FATAL: no asgat at $P (run pbuild.sh asgat)"; exit 3; }
G=$D/slpp_all/surelog.uhdm
O=$D/ours.uhdm
[ -f "$G" ] || { echo "NO_OUTPUT: golden $G absent"; exit 6; }
[ -f "$O" ] || { echo "NO_OUTPUT: ours $O absent"; exit 6; }
"$P" "$G" '' all | sort > "$D/g.asg"; grc=${PIPESTATUS[0]}
"$P" "$O" '' all | sort > "$D/o.asg"; orc=${PIPESTATUS[0]}
echo "asgat rc: golden=$grc ours=$orc"
[ "$grc" = 4 ] && echo "UNMEASURED on golden"
[ "$orc" = 4 ] && echo "UNMEASURED on ours"
echo "--- diff golden(LHS) vs ours(RHS)"
diff -u "$D/g.asg" "$D/o.asg"
echo "--- rc=$?  (0 = identical)"
echo "--- GOLDEN"; cat "$D/g.asg"
echo "--- OURS";   cat "$D/o.asg"
