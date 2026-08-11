#!/bin/bash
# r10uvm50repro/corpdump.sh — dump BOTH sides of one corpus test out of a
# verify_golden workdir, and cmp them.  Written because the pass-49 arms are
# NOT the corpus (arm a1 is cmp-EQUAL while carrying the defect, and arm a7
# carries an EXTRA defect the corpus does not have), so every corpus claim in
# this pass is read off the corpus databases themselves.
#
# LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.  uhdm-cmp takes
# (golden.uhdm, ours.uhdm) in that order.
#
#   usage: corpdump.sh <workdir> <mode> <TestName> <outdir>
#
# GUARDS (each an ops trap this campaign has paid for):
#   * uhdm-cmp EXITS 0 WHEN AN INPUT IS MISSING -> both sides existence-checked
#     before cmp; a missing side is NO_OUTPUT/exit 6, never a verdict.
#   * the golden path recorded in cmds.txt is a DIRECTORY; golden.uhdm is
#     appended here.  heads.sh once reported measured=0 for exactly this.
#   * heads are counted with `grep -c '^LHS:'` at column 0 (cmp prints
#     `decompile:` twice per head).
# +2 BIAS FIXED AT INTEGRATION (found by the pass-50 verifier, confirmed by the
# master). uhdm-dump's FIRST LINE is the DATABASE PATH, which always differs
# between golden and ours, so it contributes one `-` and one `+` to every
# `diff -u`. Drivers that reported `grep -c '^[-+]'` minus 2 (subtracting only
# the ---/+++ headers) were therefore over-counting content by EXACTLY 2. Master
# verified on a real arm: raw 48, raw-2 = 46, TRUE content = 44. Both dumps are
# now piped through `sed '1d'` -- the same thing tests/check_goldens.sh already
# does -- so every figure from this driver is real content.
set -u
WD=${1:?workdir}
MODE=${2:?default|testflags}
T=${3:?test name}
OUT=${4:?outdir}
D=$(echo "$WD/$MODE/$T"-*/ | head -1)
[ -d "$D" ] || { echo "NO_OUTPUT: no rundir for $T/$MODE under $WD"; exit 6; }
C=$D/cmds.txt
[ -f "$C" ] || { echo "NO_OUTPUT: no cmds.txt in $D"; exit 6; }
G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
[ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
O=$D/slang.uhdm
[ -n "$G" ] && [ -f "$G" ] || { echo "NO_OUTPUT: golden absent (g=${G:-none})"; exit 6; }
[ -f "$O" ] || { echo "NO_OUTPUT: ours absent ($O)"; exit 6; }
mkdir -p "$OUT" || exit 1
echo "TEST=$T MODE=$MODE"
echo "golden=$G bytes=$(stat -c %s "$G")"
echo "ours  =$O bytes=$(stat -c %s "$O")"
uhdm-dump "$G" | sed 's#/home/[^ ,]*/##g' | sed '1d' > "$OUT/g.dump" 2>&1
uhdm-dump "$O" | sed 's#/home/[^ ,]*/##g' | sed '1d' > "$OUT/o.dump" 2>&1
[ -s "$OUT/g.dump" ] || { echo "NO_OUTPUT: golden dump empty"; exit 6; }
[ -s "$OUT/o.dump" ] || { echo "NO_OUTPUT: ours dump empty"; exit 6; }
echo "g.dump lines=$(wc -l < "$OUT/g.dump")  o.dump lines=$(wc -l < "$OUT/o.dump")"
uhdm-cmp "$G" "$O" > "$OUT/cmp.txt" 2>&1
echo "cmp rc=$?  cmp lines=$(wc -l < "$OUT/cmp.txt")  heads=$(grep -c '^LHS:' "$OUT/cmp.txt")"
echo "OUT=$OUT"
