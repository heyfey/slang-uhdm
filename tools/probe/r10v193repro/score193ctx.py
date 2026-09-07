#!/usr/bin/env python3
"""r10v193 verifier — score193.py re-keyed CTX-BLIND.

MEASUREMENT ONLY.  Identical to tools/probe/r10uvm193repro/score193.py except
that the CTX column (field 3 of the census key: CALLARG / PLAIN / ...) is
dropped from the key.  CTX is a SHAPE fact, not a binding fact: golden marks a
reference inside a method call's `with` clause CALLARG and we mark it PLAIN,
a difference that predates this pass, and with CTX in the key the two rows do
not join, so a reference whose ACTUAL moved to EXACTLY golden's object scores
ONLY-OURS-MOVED.  Run BOTH and report both.
"""
import sys
from collections import Counter
def load(path, drop):
    d = {}
    for line in open(path):
        line = line.rstrip('\n')
        if not line or line.startswith('--') or '||' not in line:
            continue
        k, v = line.split('||', 1)
        fs = k.split('|')
        k = '|'.join(f for i, f in enumerate(fs) if i not in drop).strip()
        vals = tuple(sorted(x.strip() for x in v.split(';;')))
        d[k] = tuple(sorted(d.get(k, ()) + vals))
    return d
def main():
    drop = set()
    if '--noctx' in sys.argv[4:]: drop.add(3)
    if '--noface' in sys.argv[4:]: drop.add(2)
    g, a, b = (load(p, drop) for p in sys.argv[1:4])
    verbose = '-v' in sys.argv[4:]
    cnt = Counter(); detail = {c: [] for c in ('TOWARD','AWAY','MOVED-WRONG','STILL-WRONG','ONLY-OURS-MOVED','ONLY-GOLDEN','ONLY-OURS')}
    for k in set(a) | set(b) | set(g):
        va, vb, vg = a.get(k), b.get(k), g.get(k)
        if vg is None:
            if va is None and vb is None: continue
            cnt['ONLY-OURS'] += 1
            if va != vb:
                cnt['ONLY-OURS-MOVED'] += 1; detail['ONLY-OURS-MOVED'].append((k, va, vb, vg))
            continue
        if va is None and vb is None:
            cnt['ONLY-GOLDEN'] += 1; detail['ONLY-GOLDEN'].append((k, va, vb, vg)); continue
        if va == vb:
            cnt['UNTOUCHED'] += 1
            if va != vg: cnt['STILL-WRONG'] += 1; detail['STILL-WRONG'].append((k, va, vb, vg))
            continue
        if va != vg and vb == vg: cnt['TOWARD'] += 1; detail['TOWARD'].append((k, va, vb, vg))
        elif va == vg and vb != vg: cnt['AWAY'] += 1; detail['AWAY'].append((k, va, vb, vg))
        else: cnt['MOVED-WRONG'] += 1; detail['MOVED-WRONG'].append((k, va, vb, vg))
    for c in ('UNTOUCHED','TOWARD','AWAY','MOVED-WRONG','STILL-WRONG','ONLY-GOLDEN','ONLY-OURS','ONLY-OURS-MOVED'):
        print('%-16s %d' % (c, cnt[c]))
    if verbose:
        for c in ('TOWARD','AWAY','MOVED-WRONG','ONLY-OURS-MOVED','STILL-WRONG'):
            for k, va, vb, vg in sorted(detail[c])[:80]:
                print('%s %s\n    pris=%s\n    pat =%s\n    gold=%s' % (c, k, va, vb, vg))
    return 0
sys.exit(main())
