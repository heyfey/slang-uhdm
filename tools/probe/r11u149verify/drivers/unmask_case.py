#!/usr/bin/env python3
# unmask_case.py <cw dir> <refTag> <newTag>: unmask_proof.py's alignment test on one case workdir (case.sh's record dumps)
import sys, re, difflib, collections
w, a, b = sys.argv[1:4]
STRUCT = ('type', 'depth', 'count', 'name')
def recs(t):
    L = open(f'{w}/{t}.strict').read().split('\n'); d = {}
    for i, ln in enumerate(L):
        m = re.match(r'#(\d+) (\w+)', ln)
        if m: d[int(m.group(1))] = (m.group(2), L[i+1].strip()[3:], L[i+2].strip()[3:])
    return d, '(walk diverged)' in '\n'.join(L)
da, va = recs(a); db, vb = recs(b)
rdiv = min([i for i, (f, _, _) in da.items() if f in STRUCT], default=10**12) if va else 10**12
grown = [i for i in db if i not in da]; early = [i for i in grown if i < rdiv]
A = [l.rstrip('\n') for l in open(f'{w}/{a}.rec')]; B = [l.rstrip('\n') for l in open(f'{w}/{b}.rec')]
same = set()
for tg, i1, i2, j1, j2 in difflib.SequenceMatcher(None, A, B, autojunk=False).get_opcodes():
    if tg == 'equal': same.update(range(j1, j2))
chg = [i for i in grown if i not in same]
v = 'UNMASK-PROVEN' if not early and not chg else ('UNMASK+WRITTEN' if not early else 'CHECK')
print(v, w.split('/')[-1], f'{a}: n={len(da)} div@{rdiv if rdiv < 10**12 else None}', f'{b}: n={len(db)}', f'grown={len(grown)} early={len(early)} written={len(chg)}',
      '; '.join(f"#{i} {db[i][0]} gold[{db[i][1][:60]}] ours[{db[i][2][:60]}]" for i in chg[:2]))
