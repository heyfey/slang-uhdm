#!/usr/bin/env python3
"""§ ifaceDefNetTypespecIsTheModuleRule224 — THE THREE-WAY CELL SCORE.

Joins golden / pristine / patched rosters cell by cell and classes every cell:
  TO-GOLDEN   wrong on pristine, right on patched
  AWAY        right on pristine, wrong on patched      <- must be ZERO
  STILL-WRONG wrong on both
  KEPT        right on both
A cell is (holder kind, holder view, section, net name); its value is the
object kind, the typespec ACTUAL kind, and (for an array_net) its element net's
typespec.  MEASUREMENT ONLY — the judge is uhdm-cmp.
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from netcen224 import roster

def score(gd, pd, td, label):
    g, p, t = roster(gd), roster(pd), roster(td)
    keys = sorted(set(g) | set(p) | set(t))
    to = away = still = kept = 0
    lines = []
    for k in keys:
        gv, pv, tv = g.get(k), p.get(k), t.get(k)
        okp, okt = (pv == gv), (tv == gv)
        if okp and okt: kept += 1
        elif not okp and okt:
            to += 1;    lines.append('  TO-GOLDEN   %s  was=%s now=%s' % (k, pv, tv))
        elif okp and not okt:
            away += 1;  lines.append('  AWAY        %s  was=%s now=%s golden=%s' % (k, pv, tv, gv))
        else:
            still += 1; lines.append('  STILL-WRONG %s  golden=%s ours=%s' % (k, gv, tv))
    print('%s KEPT=%d TO-GOLDEN=%d AWAY=%d STILL-WRONG=%d' % (label, kept, to, away, still))
    for l in lines: print(l)
    return to, away, still

if __name__ == '__main__':
    print(*score(*sys.argv[1:5]))
