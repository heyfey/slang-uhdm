#!/usr/bin/env python3
# dumpdelta.py golden pristine law : order-blind multiset of id-stripped dump lines; lines law gained away from golden
import subprocess, sys, re, collections
D='/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump'
def lines(f):
    t = subprocess.run([D, f], capture_output=True, text=True, errors='replace').stdout
    t = re.sub(r', id:\d+', '', t); t = re.sub(r'/tmp/\S+/', '', t)
    return collections.Counter(l.strip() for l in t.splitlines() if l.strip())
G, P, L = (lines(x) for x in sys.argv[1:4])
pe = P - G; le = L - G   # extra vs golden
pm = G - P; lm = G - L   # missing vs golden
gained_extra = le - pe; gained_missing = lm - pm
fixed_extra = pe - le; fixed_missing = pm - lm
print(f'offgolden P={sum(pe.values())+sum(pm.values())} L={sum(le.values())+sum(lm.values())} newbad={sum(gained_extra.values())+sum(gained_missing.values())} fixed={sum(fixed_extra.values())+sum(fixed_missing.values())}')
for k,v in list(gained_extra.items())[:8]: print('  +L', v, k)
for k,v in list(gained_missing.items())[:8]: print('  -G', v, k)
