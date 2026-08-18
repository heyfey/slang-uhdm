#!/usr/bin/env python3
"""Per-cell normalised whole-dump multiset census: golden vs base vs patched.
NEW_WRONG = lines the BASE agreed with golden on that the PATCH does not.
FIXED     = lines the PATCH agrees with golden on that the BASE did not."""
import os, re, subprocess, sys, collections
DUMP = os.path.expanduser('~/git-repos/UHDM/build/bin/uhdm-dump')
GRID = sys.argv[1]
ID = re.compile(r', id:\d+')
def norm(path):
    r = subprocess.run([DUMP, path], capture_output=True, text=True, timeout=600)
    if r.returncode != 0: return None
    out = []
    for ln in r.stdout.split('\n')[1:]:
        ln = ID.sub('', ln)
        ln = ln.replace(GRID, '@G')
        out.append(ln)
    return collections.Counter(out)
def sub(a, b):
    c = collections.Counter()
    for k, v in a.items():
        d = v - b.get(k, 0)
        if d > 0: c[k] = d
    return c
rows = []
for name in sorted(os.listdir(GRID)):
    d = os.path.join(GRID, name)
    g = os.path.join(d, 'sl/slpp_all/surelog.uhdm')
    b = os.path.join(d, 'base.uhdm'); p = os.path.join(d, 'pat.uhdm')
    if not (os.path.exists(g) and os.path.exists(b) and os.path.exists(p)):
        print('%-24s SKIP-NOFILE' % name); continue
    G, B, P = norm(g), norm(b), norm(p)
    if G is None or B is None or P is None:
        print('%-24s DUMPFAIL' % name); continue
    bmiss, bextra = sub(G, B), sub(B, G)
    pmiss, pextra = sub(G, P), sub(P, G)
    neww = sub(pmiss, bmiss); newe = sub(pextra, bextra)
    fixm = sub(bmiss, pmiss); fixe = sub(bextra, pextra)
    nw = sum(neww.values()) + sum(newe.values())
    fx = sum(fixm.values()) + sum(fixe.values())
    verdict = 'SAME'
    if nw and fx: verdict = 'MIXED'
    elif nw: verdict = 'NEW_WRONG'
    elif fx: verdict = 'FIXED'
    print('%-24s %-10s base(miss=%d,extra=%d) pat(miss=%d,extra=%d) NEW_WRONG=%d FIXED=%d'
          % (name, verdict, sum(bmiss.values()), sum(bextra.values()),
             sum(pmiss.values()), sum(pextra.values()), nw, fx))
    if nw:
        with open('/tmp/vrgg10_newwrong.txt', 'a') as f:
            f.write('=== %s\n' % name)
            for k, v in list(neww.items())[:40]: f.write('  MISSING-NOW x%d %s\n' % (v, k))
            for k, v in list(newe.items())[:40]: f.write('  EXTRA-NOW   x%d %s\n' % (v, k))
