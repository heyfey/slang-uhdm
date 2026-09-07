#!/usr/bin/env bash
# r10earl119 — SCORE the grid: for every arm x view, every gen-scope
# cont_assign cell, GOLDEN vs PRISTINE vs PATCHED, with the verdict named.
# MEASUREMENT ONLY; the official uhdm-cmp is the judge.
#
#   CEN=<cen119> bash gridscore119.sh <griddir>
#
# Verdicts, per cell (payload = the COMPARE-VISIBLE Rhs shape):
#   SAME_AGREE   golden == pristine == patched
#   TO-GOLDEN    pristine != golden, patched == golden
#   AWAY-GOLDEN  pristine == golden, patched != golden      <-- must be 0
#   MOVED-WRONG  both wrong and patched != pristine         <-- must be 0
#   STILL-WRONG  both wrong and patched == pristine         (a named residue)
set -u
G=${1:?griddir}
CEN=${CEN:?path to cen119}
[ -x "$CEN" ] || { echo "FATAL: no cen119"; exit 3; }
tmp=$(mktemp -d /tmp/r10earl119_gs.XXXXXX) || exit 3
trap 'rm -rf "$tmp"' EXIT
for d in "$G"/*.def "$G"/*.elab; do
  [ -d "$d" ] || continue
  arm=$(basename "$d")
  for side in golden pris patched; do
    if [ -f "$d/$side.uhdm" ]; then
      "$CEN" "$d/$side.uhdm" </dev/null 2>/dev/null |
        grep '^VIEWCELL' > "$tmp/$side.tsv" || true
      echo "$arm $side cen rc=$?" >&2
    else
      : > "$tmp/$side.tsv"
      echo "$arm $side MISSING-DB" >&2
    fi
  done
  python3 - "$arm" "$tmp/golden.tsv" "$tmp/pris.tsv" "$tmp/patched.tsv" <<'PY'
import sys
from collections import Counter, defaultdict
arm = sys.argv[1]
def load(p):
    d = defaultdict(Counter)
    for line in open(p):
        f = line.rstrip('\n').split('\t')
        if len(f) < 5 or f[0] != 'VIEWCELL':
            continue
        cnt, view, key, pay = int(f[1]), f[2], f[3], f[4]
        d[(view, key)][pay] += cnt
    return d
g, p, q = load(sys.argv[2]), load(sys.argv[3]), load(sys.argv[4])
keys = set(g) | set(p) | set(q)
tally = Counter()
for k in sorted(keys):
    gg, pp, qq = g.get(k), p.get(k), q.get(k)
    if gg is None:
        v = 'NOGOLD_SAME' if pp == qq else 'NOGOLD_MOVED'
    elif pp == gg and qq == gg:
        v = 'SAME_AGREE'
    elif pp != gg and qq == gg:
        v = 'TO-GOLDEN'
    elif pp == gg and qq != gg:
        v = 'AWAY-GOLDEN'
    elif qq != pp:
        v = 'MOVED-WRONG'
    else:
        v = 'STILL-WRONG'
    tally[v] += 1
    if v != 'SAME_AGREE':
        print('  %-12s %-4s %s' % (v, k[0], k[1]))
        print('        golden=%s' % (dict(gg) if gg else None))
        print('        pris  =%s' % (dict(pp) if pp else None))
        print('        patch =%s' % (dict(qq) if qq else None))
print('ARM %-14s %s' % (arm, dict(tally)))
PY
done
