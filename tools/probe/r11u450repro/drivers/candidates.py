#!/usr/bin/env python3
"""candidates.py <outdir>: corpus rows and probe cases where a § 450 law can
fire: (a) a package with a wildcard import inside it (the import-group clones
of laws 1 to 5), (b) an interface declaration (laws 6 to 9), (c) an
associative dimension whose index is a bit/logic/reg keyword type (law 10).
Fence-filtered on /tmp/r11u450_fence.txt BEFORE any source is opened."""
import os, re, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', 'scripts'))
import verify_golden as vg
out = sys.argv[1]
fence = [l.strip() for l in open('/tmp/r11u450_fence.txt') if l.strip()]
def fenced(s): return any(f in s for f in fence)
PK = re.compile(r'\bpackage\b(.*?)\bendpackage\b', re.S)
WI = re.compile(r'\bimport\s+\w+\s*::\s*\*')
IF = re.compile(r'^\s*interface\s+(?!class\b)\w', re.M)
AX = re.compile(r'\w\s*\[\s*(bit|logic|reg)\b')
def hit(paths):
    for p in paths:
        try: t = open(p, errors='replace').read()
        except Exception: continue
        if IF.search(t) or AX.search(t): return True
        for m in PK.finditer(t):
            if WI.search(m.group(1)): return True
    return False
def srcs_of(d):
    r = []
    for dp, _ds, fs in os.walk(d):
        for f in fs:
            if f.endswith(('.sv', '.v', '.svh', '.pkg')): r.append(os.path.join(dp, f))
    return r
res = {}
sl = vg.discover_surelog(None)
res['surelog'] = sorted(n for n, (d, _c) in sl.items() if not fenced(n) and not fenced(d) and hit(srcs_of(d)))
u2 = vg.discover_uhdm2rtlil(None)
res['uhdm2rtlil'] = sorted(n for n, v in u2.items() if not fenced(n) and not fenced(str(v[0] if isinstance(v, tuple) else v)) and hit(srcs_of(v[0] if isinstance(v, tuple) else v)))
pr = []
root = os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', 'tests', 'probe')
for dp, _ds, fs in os.walk(root):
    for f in fs:
        if f.endswith(('.sv', '.v')) and not fenced(dp) and not fenced(f):
            if hit([os.path.join(dp, f)]): pr.append(os.path.relpath(os.path.join(dp, f), root))
res['probe'] = sorted(pr)
os.makedirs(out, exist_ok=True)
for k, v in res.items():
    open(os.path.join(out, k + '.txt'), 'w').write('\n'.join(v) + '\n')
    print(k, len(v))
