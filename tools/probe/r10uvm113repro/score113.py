#!/usr/bin/env python3
"""r10uvm113 score113.py — TO-GOLDEN / AWAY-GOLDEN / STILL-WRONG / ALREADY-RIGHT
per call->callee cell, for golden vs PRISTINE vs PATCHED.

MEASUREMENT ONLY; the official uhdm-cmp is the judge.

Reads three ct113cen censuses.  Ids are not comparable across producers and the
two producers disagree about macro-expansion spans, so a cell is keyed on
(view, container, owner chain, call name, call kind) and its value is the
callee SHAPE `kind|name|parentkind:parentname` — exactly what
`func_call::Compare`'s `SafeCompare(Function(), ...)` can see.

  usage: score113.py <golden.tsv> <pristine.tsv> <patched.tsv> [tag]
"""
import sys, collections

def load(path):
    d = collections.defaultdict(list)
    for ln in open(path):
        p = ln.rstrip('\n').split('\t')
        if len(p) != 7: continue
        view, top, home, call, sp, kind, callee = p
        if callee != '<null>':
            k, _, rest = callee.partition('|')
            nm, _, rest2 = rest.partition('|')
            par, _, _loc = rest2.partition('@')
            callee = '%s|%s|%s' % (k, nm, par)
        d[(view, top, home, call, kind)].append(callee)
    return d

def main():
    g, p, q = (load(a) for a in sys.argv[1:4])
    tag = sys.argv[4] if len(sys.argv) > 4 else ''
    c = collections.Counter()
    for k in sorted(set(g) | set(p) | set(q)):
        gv, pv, qv = sorted(g.get(k, [])), sorted(p.get(k, [])), sorted(q.get(k, []))
        n = max(len(gv), len(pv), len(qv))
        for i in range(n):
            a = gv[i] if i < len(gv) else '<absent>'
            b = pv[i] if i < len(pv) else '<absent>'
            d = qv[i] if i < len(qv) else '<absent>'
            if a == b == d: v = 'ALREADY-RIGHT'
            elif a != b and a == d: v = 'TO-GOLDEN'
            elif a == b and a != d: v = 'AWAY-GOLDEN'
            elif a != b and a != d and b == d: v = 'STILL-WRONG'
            else: v = 'CHANGED-STILL-WRONG'
            c[v] += 1
            if v != 'ALREADY-RIGHT':
                print('%-19s %s\tG=%s\tPRIS=%s\tPAT=%s' % (v, '\t'.join(k), a, b, d))
    print('SCORE %s  ' % tag + '  '.join('%s=%d' % (x, c[x]) for x in
          ('TO-GOLDEN', 'ALREADY-RIGHT', 'AWAY-GOLDEN', 'STILL-WRONG',
           'CHANGED-STILL-WRONG')))

main()
