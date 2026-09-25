#!/usr/bin/env python3
# unmask.py <gold> <pris.uhdm> <law.uhdm>: field-level: a law-differing field of an object that pristine
# had right (object absent from pristine's list = all fields right) is a BROKEN cell unless it sits past
# pristine's walk divergence (unmasked).
import sys, subprocess, collections
SC = '/tmp/v11u160_bin/uhdm-strictcmp'
def recs(g, o):
    r = subprocess.run([SC, '--max', '1000000', g, o], capture_output=True, text=True).stdout.splitlines()
    out = []; div = None; tail = r[-1] if r else ''
    diverged = any('(walk diverged)' in l for l in r)
    for i, l in enumerate(r):
        if l.startswith('#') and i + 2 < len(r):
            idx = int(l.split()[0][1:]); fld = l.split()[1]
            a = r[i+1].strip()[3:].split('\t'); b = r[i+2].strip()[3:].split('\t')
            out.append((idx, fld, a, b))
            if div is None and fld in ('type', 'depth'): div = idx
    return out, (div if diverged else None), tail
g, p, l = sys.argv[1:4]
P, pd, pt = recs(g, p); L, ld, lt = recs(g, l)
pm = collections.defaultdict(list)
for idx, f, a, b in P: pm['\t'.join(a)].append((f, b))
broken = []
for idx, f, a, b in L:
    k = '\t'.join(a)
    if pm[k]:
        pf, pb = pm[k].pop(0)
        bad = [i for i in range(min(len(a), len(b), len(pb))) if pb[i] == a[i] and b[i] != a[i]]
        if pf == f and bad == [4]:
            bad = []  # the same object differing in the same (hidden-by-canonical-record) fullname
        # a pre-existing record whose differing field the record text hides: same object, not new
    else:
        bad = [i for i in range(min(len(a), len(b))) if b[i] != a[i]] or ['hidden:' + f]
    if bad: broken.append((idx, f, bad, a, b))
unm = [x for x in broken if pd is not None and x[0] > pd]
real = [x for x in broken if not (pd is not None and x[0] > pd)]
v = 'CLEAN' if not broken else ('UNMASK' if not real else 'BROKEN')
print(f"{v} pris={len(P)} div@{pd} law={len(L)} div@{ld} broken={len(real)} unmasked={len(unm)} | {pt} | {lt}")
for x in real[:6]: print('   ', x[0], x[1], x[2], '\t'.join(x[3])[:90], '||', '\t'.join(x[4])[:90])
