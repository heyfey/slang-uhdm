#!/usr/bin/env bash
# r10uvm167repro/predsweep167.sh — THE A-PRIORI PREDICTION, from PRISTINE
# databases only.  MEASUREMENT ONLY; the patched binary is not run.
#
#   CEN=<ct167cen> predsweep167.sh <pristine verify_golden workdir> <out.tsv>
#
# THE LAW'S BUCKET, stated as a join: a call cell where OUR ARGUMENT VECTOR IS
# LONGER THAN GOLDEN'S.  That is the only bucket this pass can move, and its
# complement — a cell where GOLDEN is longer — is the AWAY column, reported in
# the same pass so both directions are on the record before any code is judged.
#
# A first cut predicted from OUR databases ALONE, flagging any call carrying an
# argument located outside the caller's subroutine (`ct167cen --pred`, kept for
# reference).  It over-predicted by three orders of magnitude — 22605 cells
# across 9 databases — because uvm-1.2 is built on MACROS and a macro-expanded
# `$display` argument is legitimately located in another file.  The join below
# is exact.
#
# The golden path is read out of the row's own cmds.txt (rowheads.sh's guard);
# both sides are existence-checked and a row that reaches nothing is COUNTED.
set -u
WD=${1:?pristine workdir}
OUT=${2:?out.tsv}
CEN=${CEN:?set CEN to the ct167cen binary}
T=$(mktemp -d /tmp/r10uvm167_pred.XXXXXX) || exit 1
: > "$OUT"
rows=0; skipped=0
for mode in default testflags; do
  [ -d "$WD/$mode" ] || continue
  for d in "$WD/$mode"/*/; do
    [ -d "$d" ] || continue
    n=$(basename "$d")
    O=$d/slang.uhdm
    G=""
    [ -f "$d/cmds.txt" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
    if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
      skipped=$((skipped+1)); continue
    fi
    rows=$((rows+1))
    "$CEN" "$G" R --noobj 2>/dev/null | grep '^CALL|' > "$T/g.txt" || true
    "$CEN" "$O" R --noobj 2>/dev/null | grep '^CALL|' > "$T/o.txt" || true
    python3 - "$T/g.txt" "$T/o.txt" "$mode/$n" >> "$OUT" <<'PY'
import sys, collections
def load(p):
    m = collections.defaultdict(collections.Counter)
    for l in open(p, errors='replace'):
        l = l.rstrip('\n')
        if not l:
            continue
        k, _, v = l.rpartition('|N=')
        m[k][int(v)] += 1
    return m
g = load(sys.argv[1]); o = load(sys.argv[2]); row = sys.argv[3]
for k in set(g) | set(o):
    if g[k] == o[k]:
        continue
    gs = sorted(g[k].elements()); os_ = sorted(o[k].elements())
    if not gs or not os_:
        d = 'ONESIDED'
    elif sum(os_) > sum(gs):
        d = 'OURS-LONGER'
    elif sum(os_) < sum(gs):
        d = 'GOLDEN-LONGER'
    else:
        d = 'SAME-TOTAL'
    print('%s\t%s\t%s\tG=%s\tO=%s' % (row, d, k.split('|', 2)[2], gs, os_))
PY
  done
done
rm -rf "$T"
echo "-- rows=$rows skipped=$skipped"
echo "-- directions:"; cut -f2 "$OUT" | sort | uniq -c
echo "-- OURS-LONGER, the law's bucket, BY DATABASE:"
awk -F'\t' '$2=="OURS-LONGER"{print $1}' "$OUT" | sort | uniq -c
echo "-- GOLDEN-LONGER, the AWAY direction, BY DATABASE:"
awk -F'\t' '$2=="GOLDEN-LONGER"{print $1}' "$OUT" | sort | uniq -c
