#!/bin/bash
# r10v225 — THE THREE-WAY *BASE-NET* SCORE: golden x pristine x patched.
#
#   usage: bash basedelta225.sh <pristine griddir> <patched griddir>
#
# `armdelta225.sh` scores the ARRAY_NET vector only.  R-A (`assocIdxIsBuiltin225`)
# also rewrites `defNetOmitsTypespec224`, which decides the HOLDER'S OWN
# `Nets()` entries — a field the array_net census never reads.  A regression
# there is invisible to the array_net three-way and to `uhdm-cmp` on every arm
# whose head fails earlier, so it needs its own three-way:
#
#   TO-GOLDEN    wrong or absent on pristine, EXACT on patched
#   AWAY         EXACT on pristine, wrong or absent on patched   <-- must be 0
#   STILL-WRONG  wrong or absent on both
#   SAME-RIGHT   exact on both
#
# Cells are keyed on (holder, NAME, occurrence), like armdelta225.sh, so one
# missing net does not shift every later cell.
set -u
P=${1:?pristine griddir}
Q=${2:?patched griddir}
HERE=$(cd "$(dirname "$0")" && pwd)
python3 - "$P" "$Q" "$HERE" <<'PY'
import os, sys
sys.path.insert(0, sys.argv[3])
import anetcen225 as A

pris, pat = sys.argv[1], sys.argv[2]

def cells(dump):
    out = {}
    if not os.path.exists(dump):
        return out
    holders = {}
    def walk(n):
        if n.kind in A.HOLDERS:
            full = A.get(n, 'vpiFullName') or A.get(n, 'vpiName') or n.head
            lst = A.kids(n, 'vpiNet')
            if lst and (full not in holders or len(lst) > len(holders[full])):
                holders[full] = lst
        for f, c in n.children:
            if f == 'vpiParent':
                continue
            walk(c)
    for r in A.parse(dump):
        walk(r)
    seen = {}
    for h in sorted(holders):
        for n in holders[h]:
            full = A.get(n, 'vpiFullName') or A.get(n, 'vpiName')
            k = (h, full)
            i = seen.get(k, 0)
            seen[k] = i + 1
            out[(h, full, i)] = 'nt=%s ts=%s' % (A.get(n, 'vpiNetType', '-'),
                                                 A.ts_of(n))
    return out

tg = aw = sw = sr = 0
rows = []
for arm in sorted(os.listdir(pris)):
    gd = os.path.join(pris, arm, 'golden.dump')
    if not os.path.exists(gd):
        continue
    g = cells(gd)
    o1 = cells(os.path.join(pris, arm, 'ours.dump'))
    o2 = cells(os.path.join(pat, arm, 'ours.dump'))
    a = b = c = d = 0
    for k in sorted(set(g) | set(o1) | set(o2)):
        gv, p1, p2 = g.get(k), o1.get(k), o2.get(k)
        ok1, ok2 = (gv is not None and p1 == gv), (gv is not None and p2 == gv)
        if gv is None:
            ok1, ok2 = p1 is None, p2 is None
        if ok1 and ok2:
            d += 1
        elif not ok1 and ok2:
            a += 1
        elif ok1 and not ok2:
            b += 1
            rows.append('  AWAY %s %s %s\n    G %s\n    PRIS %s\n    PAT %s'
                        % (arm, k[0], k[1], gv, p1, p2))
        else:
            c += 1
    print('ARM %-16s golden=%-3d TO-GOLDEN=%-3d AWAY=%-2d STILL-WRONG=%-3d '
          'SAME-RIGHT=%d' % (arm, len(g), a, b, c, d))
    tg += a; aw += b; sw += c; sr += d
print('TOTAL  TO-GOLDEN=%d  AWAY=%d  STILL-WRONG=%d  SAME-RIGHT=%d'
      % (tg, aw, sw, sr))
for r in rows:
    print(r)
PY
