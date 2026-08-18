#!/usr/bin/env python3
# r10earl66 — rank the "golden folds / we do not" SUPERFAMILY by position and
# by the kind of the symbol we keep a ref_obj to.  MEASUREMENT ONLY.
import sys, re
from collections import defaultdict, Counter
def load(p):
    d = defaultdict(list)
    for ln in open(p):
        f = ln.rstrip('\n').split(' ')
        d[' '.join(f[:5])].append(' '.join(f[5:]))
    return d
g, o = load(sys.argv[1]), load(sys.argv[2])
def pos(site, path):
    st = site.split('_')[0] if not site.startswith(('HC_','CA_','PA_','VAR_')) else site.split('_')[0]
    if site.startswith('HC'): st='HC'
    elif site.startswith('CA'): st='CA'
    elif site.startswith('PA'): st='PA'
    elif site.startswith('VAR'): st='VAR'
    tail = path.split('/')[-1]
    tail = re.sub(r'op(\d+)\[\d+\]', r'op\1[]', tail)
    tail = re.sub(r'hp\[\d+\]', 'hp[]', tail)
    tail = re.sub(r'e\[\d+\]', 'e[]', tail)
    tail = re.sub(r'arg\[\d+\]', 'arg[]', tail)
    tail = re.sub(r'sarg\[\d+\]', 'sarg[]', tail)
    tail = re.sub(r'tp:.*', 'tp:', tail)
    return st, tail
by = Counter(); byname = Counter(); bysec = Counter(); rows=defaultdict(list)
for k in set(g) | set(o):
    G, O = sorted(g.get(k, [])), sorted(o.get(k, []))
    n = max(len(G), len(O)); G += ['<none>']*(n-len(G)); O += ['<none>']*(n-len(O))
    kf = k.split(' ')
    sec, owner, site, path = kf[1], kf[2], kf[3], kf[4]
    for i in range(n):
        if G[i]==O[i]: continue
        gk = G[i].split(' ')[0]; ok = O[i].split(' ')[0]
        if not (gk=='constant' and ok=='ref_obj'): continue
        st, tail = pos(site, path)
        m = re.search(r'actual=(\S+)', O[i]); ak = m.group(1) if m else '-'
        nm = re.search(r'name=(\S+)', O[i]); nmv = nm.group(1) if nm else '-'
        by[(sec, st, tail, ak)] += 1
        byname[(ak, nmv)] += 1
        bysec[(sec,st)] += 1
        rows[(sec,st,tail,ak)].append((k, G[i], O[i]))
print('=== by (sec, site, position, referenced-kind) ===')
for kk, c in by.most_common(int(sys.argv[3]) if len(sys.argv)>3 else 30):
    print(f'{c:6d}  sec={kk[0]:5s} site={kk[1]:4s} pos={kk[2]:14s} refkind={kk[3]}')
print('TOTAL', sum(by.values()))
print('=== by (referenced-kind, name) top 25 ===')
for kk, c in byname.most_common(25):
    print(f'{c:6d}  {kk[0]:16s} {kk[1]}')
print('=== by (sec, site) ===')
for kk,c in bysec.most_common(): print(f'{c:6d} {kk}')
if len(sys.argv)>4:
    sel=sys.argv[4]
    for kk,rr in rows.items():
        if '|'.join(kk)==sel:
            for r in rr[:12]: print('  ', r[0], '| G', r[1], '| O', r[2])
