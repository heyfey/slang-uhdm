#!/bin/bash
# r10uvm55repro/asgcen.sh — run asgat on BOTH sides of one row of a
# verify_golden workdir and diff the two listings.
#
# LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.
#
#   usage: asgcen.sh <workdir> <TestName> <mode> <fileSubstring> <line> <outdir>
#
# GUARDS: both databases existence-checked first (exit 6); asgat's own exit 4
# (`UNMEASURED: 0 objects matched`) is reported per side and NOT swallowed.
set -u
WD=${1:?workdir}; NAME=${2:?test}; MODE=${3:?mode}
FS=${4:?file substring}; LN=${5:?line}; OUT=${6:?outdir}
P=${ASGAT:-/tmp/r10uvm55_asgat}
[ -x "$P" ] || { echo "FATAL: no asgat at $P (run pbuild.sh asgat)"; exit 3; }
D=$(echo "$WD/$MODE/$NAME"-*/ | cut -d' ' -f1)
[ -d "$D" ] || { echo "FATAL: no row dir for $NAME/$MODE under $WD"; exit 3; }
O=$D/slang.uhdm
G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$D/cmds.txt" | head -1)
[ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
[ -f "$G" ] || { echo "NO_OUTPUT: golden absent (${G:-none})"; exit 6; }
[ -f "$O" ] || { echo "NO_OUTPUT: ours absent ($O)"; exit 6; }
mkdir -p "$OUT" || exit 1
"$P" "$G" "$FS" "$LN" > "$OUT/g.asg"; grc=$?
"$P" "$O" "$FS" "$LN" > "$OUT/o.asg"; orc=$?
echo "$NAME/$MODE $FS:$LN  asgat rc: golden=$grc ours=$orc"
echo "--- GOLDEN (LHS)"; cat "$OUT/g.asg"
echo "--- OURS (RHS)";   cat "$OUT/o.asg"
