#!/usr/bin/env python3
"""r10buvm11repro/cenjoin11.py — JOIN two census files on an ID-BLIND,
ADDRESS-BLIND key and classify the array_var ELEMENT-RANGE question.

    usage: cenjoin11.py <golden.cen> G <ours.cen> P

LHS is ALWAYS golden.  The key is (view, parent chain of kinds+names, name,
line:col) — no object id, no address, nothing allocation-ordered.  The CELL is
the pair (element kind, element range marker shape), because those are the two
things the law decides; the array_var's own marker shape rides along so a
disagreement can be told apart from a disagreement about the ARRAY's ranges,
which is a DIFFERENT defect and must not be counted as this one.

Classes printed:
    G=R P=R  both give the element a range vector
    G=N P=N  neither does
    G=R P=N  golden does, we do NOT      <- what this pass removes
    G=N P=R  we do, golden does NOT      <- an over-fire, must stay 0
    one-sided keys (the object exists on one side only) are counted separately
    and are NOT this law's business.
"""
import sys, collections

def load(path, tag):
    rows = {}
    with open(path) as f:
        for ln in f:
            p = ln.split()
            if not p or p[0] != 'AV' or p[1] != tag:
                continue
            d = {}
            for tok in p[2:]:
                if '=' in tok:
                    k, v = tok.split('=', 1)
                    d[k] = v
            key = (d.get('view', ''), d.get('key', ''))
            rows[key] = (d.get('ek', '-'), d.get('evM', '-'), d.get('avM', '-'))
    return rows

def main():
    g = load(sys.argv[1], sys.argv[2])
    p = load(sys.argv[3], sys.argv[4])
    cls = collections.Counter()
    bad = []
    for k in set(g) | set(p):
        if k not in g:
            cls['P-only'] += 1; continue
        if k not in p:
            cls['G-only'] += 1; continue
        gr = g[k][1] not in ('-', '()')
        pr = p[k][1] not in ('-', '()')
        name = 'G=%s P=%s' % ('R' if gr else 'N', 'R' if pr else 'N')
        cls[name] += 1
        if gr != pr:
            bad.append((name, k, g[k], p[k]))
    for k in sorted(cls):
        print('%-10s %d' % (k, cls[k]))
    for n, k, gv, pv in sorted(bad):
        print('  %-8s %s %s  G(ek=%s evM=%s avM=%s) P(ek=%s evM=%s avM=%s)' %
              (n, k[0], k[1], gv[0], gv[1], gv[2], pv[0], pv[1], pv[2]))
    print('DISAGREEING %d' % len(bad))

main()
