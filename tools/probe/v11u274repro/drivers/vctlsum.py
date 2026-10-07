#!/usr/bin/env python3
# v11u274 vctlsum.py <controls.txt>: per case-view, pristine / law / fix (vcontrols.sh lines): movers of the law
# and of the fix against pristine (entering, leaving STRICT_EQUAL, exit-code and uhdm-cmp changes) and every
# case-view where the fix differs from the law.  MOVER lines carry pristine -> fix for the away census.
import sys, re, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    w = l.split(' ', 3)
    if len(w) == 4: rows[(w[0], w[1])][w[2]] = w[3].strip()
f = lambda s, k: (re.search(k + r'=(\S+)', s) or [None, ''])[1]
eq = lambda s: 'STRICT_EQUAL' in s
st = lambda s: re.sub(r' md5=\S+', '', s)
def tally(a, b):
    mv = [k for k, r in rows.items() if f(r[a], 'md5') != f(r[b], 'md5')]
    return (len(mv), sum(eq(rows[k][b]) and not eq(rows[k][a]) for k in mv), sum(eq(rows[k][a]) and not eq(rows[k][b]) for k in mv),
            sum(f(r[a], 'rc') != f(r[b], 'rc') for r in rows.values()), sum(f(r[a], 'cmp') != f(r[b], 'cmp') for r in rows.values()), mv)
for (c, v), r in sorted(rows.items()):
    if f(r['pristine'], 'md5') != f(r['fix'], 'md5'):
        print(f'MOVER {c} {v}: {st(r["pristine"])} -> {st(r["fix"])}' + ('' if f(r['law'], 'md5') == f(r['fix'], 'md5') else f'  [law: {st(r["law"])}]'))
    elif f(r['law'], 'md5') != f(r['fix'], 'md5'):
        print(f'LAWONLY {c} {v}: pristine/fix {st(r["pristine"])} law {st(r["law"])}')
for a, b in (('pristine', 'law'), ('pristine', 'fix'), ('law', 'fix')):
    n, e, l, rc, cm, _ = tally(a, b)
    print(f'{a} -> {b}: case-views {len(rows)} moving {n} entering {e} leaving {l} rc-changed {rc} cmplines-changed {cm}')
