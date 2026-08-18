#!/usr/bin/env python3
"""r10buvm24repro/gridcmp24.py — the THREE-WAY scorer.  MEASUREMENT ONLY.

    gridcmp24.py <cen.golden> <cen.pristine> <cen.patched> [--show] [--x]

CELL = one (call loc, call kind, call name) slot of a MULTISET.  The
ARGUMENT-COUNT is deliberately NOT in the key — this law CHANGES it (a LEADING
empty slot drops an argument, and a cloned call-valued default disappears
entirely), and a key that carried the count would score those cells as
GOLDEN-ONLY/OURS-ONLY instead of FIXED.  Identical keys are paired off by
sorted payload; a side with fewer rows for a key gets the sentinel `<absent>`
so nothing is silently dropped (never a last-writer dict).

The payload is the JUDGE-VISIBLE argument signature only.  `--x` scores the
NON-judge-visible companion (value / span / parent) instead, which is how the
"unparented, at the call site" half of the model is checked; no generated
`Compare` reads any of it.

  FIXED        pristine != golden, patched == golden
  BROKEN       pristine == golden, patched != golden      <- the load-bearing 0
  STILL-WRONG  neither matches golden
  STILL-RIGHT  both match golden

`--ms` scores the same three files as a TRUE MULTISET INTERSECTION per key
(sum over payloads of min(count)) instead of by sorted position.  It is the
honest number whenever a law CHANGES the number of objects at a key: positional
pairing then re-aligns surviving rows against different golden rows and can
report a BROKEN cell for a defect that was already there.  It prints, per side,
how many objects match golden and how many are SURPLUS.
"""
import sys, collections

def load(p, col):
    d = collections.defaultdict(list)
    for ln in open(p, encoding='utf-8', errors='replace'):
        f = ln.rstrip('\n').split('\t')
        if len(f) < 8 or f[1] != 'CALL':
            continue
        d[(f[2], f[3], f[4])].append(f[col])
    for k in d:
        d[k].sort()
    return d

def ms(G, P, Q, show):
    keys = sorted(set(G) | set(P) | set(Q))
    ng = np = nq = mp = mq = 0
    for k in keys:
        cg = collections.Counter(G.get(k, []))
        cp = collections.Counter(P.get(k, []))
        cq = collections.Counter(Q.get(k, []))
        ng += sum(cg.values()); np += sum(cp.values()); nq += sum(cq.values())
        a = sum((cg & cp).values()); b = sum((cg & cq).values())
        mp += a; mq += b
        if show and (a != b or sum(cp.values()) != sum(cq.values())):
            print('KEY\t%s\n  G %s\n  P %s\n  Q %s' %
                  ('\t'.join(k), dict(cg), dict(cp), dict(cq)))
    print('OBJECTS golden %d  pristine %d  patched %d' % (ng, np, nq))
    print('MATCHING GOLDEN  pristine %d  patched %d   (TO-GOLDEN %+d)'
          % (mp, mq, mq - mp))
    print('SURPLUS (objects golden has not) pristine %d  patched %d'
          % (np - mp, nq - mq))

def main():
    a = [x for x in sys.argv[1:] if not x.startswith('--')]
    show = '--show' in sys.argv
    col = 7 if '--x' in sys.argv else 6
    G, P, Q = (load(x, col) for x in a[:3])
    if '--ms' in sys.argv:
        return ms(G, P, Q, show)
    keys = sorted(set(G) | set(P) | set(Q))
    fixed = broken = sw = sr = 0
    for k in keys:
        g, p, q = G.get(k, []), P.get(k, []), Q.get(k, [])
        n = max(len(g), len(p), len(q))
        for i in range(n):
            gv = g[i] if i < len(g) else '<absent>'
            pv = p[i] if i < len(p) else '<absent>'
            qv = q[i] if i < len(q) else '<absent>'
            if pv == gv and qv == gv:
                sr += 1
            elif pv != gv and qv == gv:
                fixed += 1
                if show:
                    print('FIXED\t%s\n  G %s\n  P %s' % ('\t'.join(k), gv, pv))
            elif pv == gv and qv != gv:
                broken += 1
                print('BROKEN\t%s\n  G %s\n  Q %s' % ('\t'.join(k), gv, qv))
            else:
                sw += 1
                if show:
                    print('STILL-WRONG\t%s\n  G %s\n  P %s\n  Q %s'
                          % ('\t'.join(k), gv, pv, qv))
    print('CELLS %d   FIXED %d  BROKEN %d  STILL-WRONG %d  STILL-RIGHT %d'
          % (fixed + broken + sw + sr, fixed, broken, sw, sr))

main()
