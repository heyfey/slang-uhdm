#!/bin/bash
# r10uvm225 — THE THREE-WAY ARRAY_NET SCORE: golden x pristine x patched.
#
#   usage: bash armdelta225.sh <pristine griddir> <patched griddir>
#
# `gscore225.sh` keys a cell on its POSITION in the holder's `Array_nets()`
# vector, which is what the judge compares — but a single MISSING cell then
# shifts every later one and a three-way read of that is noise.  This scorer
# keys on (holder, NAME, occurrence-of-that-name) instead, so a cell keeps its
# identity across the two binaries, and reports:
#
#   TO-GOLDEN    wrong or absent on pristine, EXACT on patched
#   AWAY         EXACT on pristine, wrong or absent on patched   <-- must be 0
#   STILL-WRONG  wrong or absent on both
#   SAME-RIGHT   exact on both
#
# The compared field string is `anetcen225.py`'s, which includes the INNER
# ELEMENT NET's `vpiNetType` — the judge-visible field r10v224's R-C recorded
# `netcen224.py` as blind to.
set -u
P=${1:?pristine griddir}
Q=${2:?patched griddir}
HERE=$(cd "$(dirname "$0")" && pwd)
python3 - "$P" "$Q" "$HERE" <<'PY'
import os, subprocess, sys
pris, pat, here = sys.argv[1], sys.argv[2], sys.argv[3]

def cells(dump):
    out = {}
    if not os.path.exists(dump):
        return out
    txt = subprocess.run([sys.executable, os.path.join(here, 'anetcen225.py'),
                          dump], capture_output=True, text=True).stdout
    seen = {}
    for ln in txt.splitlines():
        if not ln.startswith('CELL '):
            continue
        k, _, v = ln[5:].partition(' | ')
        holder, _, full = k.partition(']=')
        holder = holder.split('[')[0]
        key = (holder, full)
        n = seen.get(key, 0)
        seen[key] = n + 1
        out[(holder, full, n)] = v
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
    keys = set(g) | set(o1) | set(o2)
    a = b = c = d = 0
    for k in sorted(keys):
        gv, p1, p2 = g.get(k), o1.get(k), o2.get(k)
        ok1, ok2 = (gv is not None and p1 == gv), (gv is not None and p2 == gv)
        # a cell golden does not have at all is EXACT only when we do not
        # either
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
