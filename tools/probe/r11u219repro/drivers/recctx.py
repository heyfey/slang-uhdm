#!/usr/bin/env python3
"""recctx.py <golden> <off> <on> <scratch> <record-regex>: for every flat record matching the regex, the per-chain
counts golden / off / on where off and on differ (the decomposition of a flat-key away count into chain contexts)."""
import sys, os, re, subprocess, collections
SC = os.environ.get('STRICT_CMP')
if not SC: sys.exit('recctx.py: source drivers/env.sh first')
def recs(u, wd, tag, rx):
    t = f'{wd}/{tag}.rec'
    subprocess.run([SC, '--max', '0', '--dump-a', t, '--dump-b', '/dev/null', u, u], capture_output=True, timeout=7200)
    ck = collections.Counter(); st = []
    for l in open(t, errors='replace'):
        f = l.rstrip('\n').split('\t')
        if not f[0].isdigit(): continue
        d = int(f[0]); st = st[:d]; rec = '\t'.join(f[1:])
        if rx.search(rec): ck[(' < '.join(reversed(st)), rec)] += 1
        st.append(f'{f[1]}:{f[2]}')
    os.remove(t); return ck
g, o, n, wd, r = sys.argv[1:6]; rx = re.compile(r); os.makedirs(wd, exist_ok=True)
G = recs(g, wd, 'g', rx); O = recs(o, wd, 'o', rx); N = recs(n, wd, 'n', rx)
tot = collections.Counter()
for k in sorted(set(O) | set(N)):
    if O[k] != N[k]:
        print(f'G={G[k]} OFF={O[k]} ON={N[k]}  {k[1]!r}  @ {k[0][:500]}')
for name, C in (('golden', G), ('off', O), ('on', N)):
    print(name, sum(C.values()))
