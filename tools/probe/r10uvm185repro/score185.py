#!/usr/bin/env python3
"""r10uvm185 — score one grid cell set: golden vs pristine vs patched.

MEASUREMENT ONLY.  `uhdm-cmp` is the judge.
LHS is ALWAYS golden; the two RHS columns are ours.

    usage: score185.py <golden.tsv> <pristine.tsv> <patched.tsv>

Key = (vpiFullName, the function's START line:col, hasStmt, parentKind:name);
the value multiset under one key is SORTED and paired BY POSITION, because a
package's DEF and ELAB listings legitimately carry the same method twice and a
last-writer dict would drop one of them (RESUME.md §9, census traps).

The scored field is the `Return` variable's VARIABLE CLASS.  The return-var SPAN
is carried in the printed row but never scored: no generated `Compare` reads a
line or a column, and this law does not move it (R1).
"""
import sys, collections

def load(p):
    rows = collections.defaultdict(list)
    for line in open(p):
        t = line.rstrip('\n').split('\t')
        if len(t) != 9 or t[0] != 'FN':
            continue
        _, fn, span, stmt, par, rk, rspan, tsk, tsn = t
        rows[(fn, span.split('-')[0], stmt, par)].append((rk, rspan, tsk, tsn))
    for k in rows:
        rows[k].sort()
    return rows

def main():
    g, p, q = (load(a) for a in sys.argv[1:4])
    c = collections.Counter()
    lines = []
    for key in sorted(set(g) | set(p) | set(q)):
        gv, pv, qv = g.get(key, []), p.get(key, []), q.get(key, [])
        n = max(len(gv), len(pv), len(qv))
        for i in range(n):
            a = gv[i][0] if i < len(gv) else None
            b = pv[i][0] if i < len(pv) else None
            d = qv[i][0] if i < len(qv) else None
            aspan = gv[i][1] if i < len(gv) else '-'
            bspan = pv[i][1] if i < len(pv) else '-'
            dspan = qv[i][1] if i < len(qv) else '-'
            if a is None:
                v = 'O-ONLY'
            elif b is None or d is None:
                v = 'G-ONLY'
            elif b == d == a:
                v = 'AGREE'
            elif b != a and d == a:
                v = 'TOWARD'
            elif b == a and d != a:
                v = 'AWAY'
            elif b == d:
                v = 'STAY-BAD'
            else:
                v = 'MOVED-WRONG'
            c[v] += 1
            if v != 'AGREE':
                lines.append('     %-11s %s %s stmt=%s  G=%s@%s PRIS=%s@%s '
                             'PAT=%s@%s' % (v, key[0], key[1], key[2], a, aspan,
                                            b, bspan, d, dspan))
    print('   ' + ' '.join('%s=%d' % kv for kv in sorted(c.items())))
    for l in lines:
        print(l)

main()
