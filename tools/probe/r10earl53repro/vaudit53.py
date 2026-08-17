#!/usr/bin/env python3
"""3-way TS+EXPR audit over hier_path census keys: golden vs pristine vs patched.
Reports, on SHARED keys, movement on BOTH axes (typespec AND vpiExpr/Root_value),
which the implementer's key output omitted for vpiExpr."""
import subprocess, sys, collections
CEN = __import__('os').path.join(__import__('os').path.dirname(__file__), 'vhpcens53.py')

def load(p):
    out = subprocess.run([sys.executable, CEN, p, '--key'], capture_output=True,
                         text=True).stdout
    d = {}
    for ln in out.splitlines():
        f = ln.split('\t')
        if len(f) < 8:
            continue
        d[(f[0], f[1], f[2], f[3], f[4])] = (f[6], f[7])   # tsactual, expr
    return d

g, p, q = (load(x) for x in sys.argv[1:4])
keys = set(g) | set(p) | set(q)
shared = [k for k in keys if k in g and k in q]
def cnt(pred, side):
    return [k for k in shared if pred(g[k], side[k])]
res = collections.Counter()
detail = collections.defaultdict(list)
for k in shared:
    for ax, i in (('TS', 0), ('EXPR', 1)):
        G, P, Q = g[k][i], p.get(k, ('-', '-'))[i], q[k][i]
        if Q == G and P == G:
            res[ax + ' same-both'] += 1
        elif Q == G and P != G:
            res[ax + ' FIXED'] += 1; detail[ax + ' FIXED'].append((k, P, Q))
        elif Q != G and P == G:
            res[ax + ' BROKEN'] += 1; detail[ax + ' BROKEN'].append((k, P, Q))
        elif Q != G and P != G and Q != P:
            if G == '-':
                res[ax + ' EXTRA-new'] += 1; detail[ax + ' EXTRA-new'].append((k, P, Q))
            else:
                res[ax + ' CHANGED-still-wrong'] += 1
                detail[ax + ' CHANGED-still-wrong'].append((k, P, Q))
        else:
            res[ax + ' unchanged-wrong'] += 1
print('golden=%d pristine=%d patched=%d shared(g&q)=%d' % (len(g), len(p), len(q), len(shared)))
print('golden-only keys=%d  patched-only keys=%d' % (len(set(g)-set(q)), len(set(q)-set(g))))
for k in sorted(res):
    print('  %-28s %d' % (k, res[k]))
for cat in ('TS BROKEN', 'EXPR BROKEN', 'TS EXTRA-new', 'EXPR EXTRA-new',
            'TS CHANGED-still-wrong', 'EXPR CHANGED-still-wrong'):
    if detail[cat]:
        print('--- %s (%d) ---' % (cat, len(detail[cat])))
        for k, P, Q in detail[cat][:25]:
            print('   %s\n       G=%s P=%s Q=%s' % ('|'.join(k), g[k], P, Q))
