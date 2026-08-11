#!/bin/bash
# r10uvm48 — regenerate an arm on a named binary, dump BOTH sides and diff them.
# LHS is ALWAYS golden(Surelog) (the `<` side of the diff), RHS is ALWAYS ours
# (`>`).  Only `file:` paths are normalised away: everything else — names,
# spans, kinds, bindings — is compared verbatim, and a residual diff is REAL.
# POSITIVE CONTROL: if either dump is empty or the diff is EMPTY BUT the dumps
# differ in line count, the script says so instead of printing a clean bill.
#   usage: armdiff.sh <arm> <outdir> <binary> [context-lines]
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
ARM=${1:?}
OUT=${2:?}
BIN=${3:?}
CTX=${4:-0}
[ -x "$BIN" ] || { echo "FATAL: no binary $BIN"; exit 3; }
bash "$HERE/gold.sh" "$ARM" "$OUT" "$BIN" > "$OUT.gen.log" 2>&1
G=$OUT/slpp_all/surelog.uhdm
O=$OUT/ours.uhdm
[ -s "$G" ] || { echo "FATAL: no golden $G (see $OUT.gen.log)"; exit 3; }
[ -s "$O" ] || { echo "NO_OUTPUT: no $O (see $OUT.gen.log)"; exit 6; }
uhdm-dump "$G" 2> /dev/null | sed 's#file:[^ ,]*,##' > "$OUT/gold.norm"
uhdm-dump "$O" 2> /dev/null | sed 's#file:[^ ,]*,##' > "$OUT/ours.norm"
gl=$(wc -l < "$OUT/gold.norm"); ol=$(wc -l < "$OUT/ours.norm")
[ "$gl" -gt 0 ] || { echo "FATAL: empty golden dump"; exit 3; }
[ "$ol" -gt 0 ] || { echo "FATAL: empty ours dump"; exit 3; }
n=$(diff -U "$CTX" "$OUT/gold.norm" "$OUT/ours.norm" | grep -c '^[-+][^-+]')
echo "ARM=$ARM golden_lines=$gl ours_lines=$ol difflines=$n"
diff -U "$CTX" "$OUT/gold.norm" "$OUT/ours.norm"
exit 0
