#!/usr/bin/env bash
# r10uvm169repro/predsweep169.sh — THE A-PRIORI PREDICTION AND THE CENSUS, from
# PRISTINE databases only.  MEASUREMENT ONLY; the patched binary is never run.
#
#   CEN=<ct169cen> predsweep169.sh <pristine verify_golden workdir> <out.tsv>
#
# For every row of the workdir it censuses the RETURN CELLS of BOTH databases
# (golden = LHS, ours = RHS) and joins them as MULTISETS keyed by
# <owning subroutine vpiFullName> x <return_stmt span>.  A key whose two
# multisets differ is printed with BOTH sides, classified:
#
#   OURS-REF-GOLDEN-CONST   this pass's bucket: golden folded, we referenced.
#   OURS-CONST-GOLDEN-REF   the AWAY direction: golden kept a reference and we
#                           folded.  Reported in the SAME pass so both columns
#                           are on the record before any code is judged.
#   OTHER                   any other disagreement (payload, count, kind).
#
# The golden path is read out of the row's own cmds.txt (rowheads.sh's guard);
# both sides are existence-checked and a row that reaches nothing is COUNTED,
# never silently skipped.
set -u
WD=${1:?pristine workdir}
OUT=${2:?out.tsv}
CEN=${CEN:?set CEN to the ct169cen binary}
[ -x "$CEN" ] || { echo "FATAL: no ct169cen at $CEN"; exit 3; }
T=$(mktemp -d /tmp/r10uvm169_pred.XXXXXX) || exit 1
trap 'rm -rf "$T"' EXIT
: > "$OUT"
rows=0; skipped=0; failed=0
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
    "$CEN" "$G" G --noobj > "$T/g.txt" 2>"$T/ge.txt" || failed=$((failed+1))
    "$CEN" "$O" O --noobj > "$T/o.txt" 2>"$T/oe.txt" || failed=$((failed+1))
    python3 - "$T/g.txt" "$T/o.txt" "$mode/$n" >> "$OUT" <<'PY'
import sys, collections
def load(p):
    m = collections.defaultdict(collections.Counter)
    for l in open(p, errors='replace'):
        l = l.rstrip('\n')
        if not l.startswith('RET|'):
            continue
        f = l.split('|')
        # RET | tag | owner | span | payload
        key = f[2] + '|' + f[3]
        m[key]['|'.join(f[4:])] += 1
    return m
g = load(sys.argv[1]); o = load(sys.argv[2]); row = sys.argv[3]
for k in sorted(set(g) | set(o)):
    if g[k] == o[k]:
        continue
    gs = g[k]; os_ = o[k]
    gref = sum(v for p, v in gs.items() if p.startswith('K=ref_obj'))
    gcst = sum(v for p, v in gs.items() if p.startswith('K=constant'))
    oref = sum(v for p, v in os_.items() if p.startswith('K=ref_obj'))
    ocst = sum(v for p, v in os_.items() if p.startswith('K=constant'))
    if oref > gref and gcst > ocst:
        d = 'OURS-REF-GOLDEN-CONST'
    elif ocst > gcst and gref > oref:
        d = 'OURS-CONST-GOLDEN-REF'
    else:
        d = 'OTHER'
    print('%s\t%s\t%s\tG=%s\tO=%s' % (row, d, k,
          sorted(gs.elements()), sorted(os_.elements())))
PY
  done
done
echo "-- rows=$rows skipped=$skipped censusfail=$failed"
echo "-- directions:"; cut -f2 "$OUT" | sort | uniq -c
echo "-- OURS-REF-GOLDEN-CONST (this pass's bucket) BY DATABASE:"
awk -F'\t' '$2=="OURS-REF-GOLDEN-CONST"{print $1}' "$OUT" | sort | uniq -c
echo "-- OURS-CONST-GOLDEN-REF (the AWAY direction) BY DATABASE:"
awk -F'\t' '$2=="OURS-CONST-GOLDEN-REF"{print $1}' "$OUT" | sort | uniq -c
