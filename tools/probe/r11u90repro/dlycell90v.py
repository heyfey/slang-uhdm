#!/usr/bin/env python3
"""v11u90 LAW B cell scorer: every vpiDelay subtree, per arm, as a MULTISET,
golden vs pristine and golden vs law.  The per-cell net/cell scorer is blind
to a field INSIDE a cont_assign, so this instrument scores that field on its
own.  Spans are kept; workdir paths are stripped by the dumper already."""
import os, re, sys, collections
GRID = sys.argv[1] if len(sys.argv) > 1 else os.environ.get('GRID', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'grid.verifier'))

def delays(p):
    out = collections.Counter()
    lines = open(p, errors='replace').read().split('\n')
    i = 0
    while i < len(lines):
        m = re.match(r'^(\s*)\|vpiDelay:\s*$', lines[i])
        if m:
            ind = len(m.group(1)); blk = []
            j = i + 1
            while j < len(lines):
                ln = lines[j]
                if not ln.strip():
                    break
                cur = len(ln) - len(ln.lstrip())
                if cur < ind or (cur == ind and ln.lstrip().startswith('|')):
                    break
                blk.append(ln.strip()); j += 1
            out['\n'.join(blk)] += 1
            i = j; continue
        i += 1
    return out

mw = aw = 0
rows = []
for a in sorted(os.listdir(GRID)):
    d = os.path.join(GRID, a)
    g, p, l = (os.path.join(d, x) for x in ('gold.dump','pris.dump','lawx.dump'))
    if not all(os.path.exists(x) for x in (g,p,l)): continue
    G, P, L = delays(g), delays(p), delays(l)
    if not (G or P or L): continue
    pm = sum((G & P).values()); lm = sum((G & L).values())
    pg = sum(G.values()); pp = sum(P.values()); lp = sum(L.values())
    if pm != lm or pp != lp:
        rows.append((a, pg, pp, pm, lp, lm))
    if lm < pm: mw += 1
    # AWAY: a golden delay that pristine matched and law does not
    lost = (G & P) - (G & L)
    if lost: aw += sum(lost.values())
print('%-24s %5s %5s %5s %5s %5s' % ('arm','gold','pris','p=g','law','l=g'))
for r in rows: print('%-24s %5d %5d %5d %5d %5d' % r)
print()
print('arms where law matches FEWER golden delays than pristine =', mw)
print('golden delays pristine matched and law does NOT (AWAY) =', aw)
