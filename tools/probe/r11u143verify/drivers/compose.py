#!/usr/bin/env python3
"""compose.py: the composition census over the six sweeps. bits = (133 on, 141 on, 137 on [+139 +v137]).
Per corpus: strict-equal counts per config; judge-equal status changes across configs; NON-MONOTONE rows (equal in a
config, not equal in one with a superset of landings on: a cancellation suspect); equal-signature of every row that
is equal at ON and not at A3 (which landings it needs)."""
import csv, collections
CF={'ON':(1,1,1),'33':(0,1,1),'37':(1,1,0),'3B':(0,1,0),'A3':(0,0,0),'41':(1,0,1)}
def load(tag, corp):
    d={}
    for r in csv.DictReader(open(f'/tmp/r11u143_wd{tag}/{corp}.csv')):
        k=(r.get('name') or r.get('case'))+(','+r['mode'] if 'mode' in r else '')
        d[k]=(r['status'], r.get('strict',''))
    return d
for corp in ('surelog','uhdm2rtlil','probe'):
    D={t:load(t,corp) for t in CF}; keys=set(D['ON'])
    for t in CF: assert set(D[t])==keys,(corp,t)
    eq=lambda t,k: D[t][k][0] in ('CMP_EQUAL','EQUAL')
    je=lambda t,k: D[t][k][0] in ('CMP_EQUAL','EQUAL','STRICT_NOTEQUAL')
    print(f'== {corp}: {len(keys)} rows; strict-equal', ' '.join(f'{t}={sum(eq(t,k) for k in keys)}' for t in CF))
    print('   judge-equal status differs across configs:', sum(1 for k in keys if len({je(t,k) for t in CF})>1))
    print('   csv identical 41 vs ON:', all(D['41'][k]==D['ON'][k] for k in keys), '; A3 vs 3B:', all(D['A3'][k]==D['3B'][k] for k in keys))
    nonmono=[]; sig=collections.defaultdict(list)
    for k in sorted(keys):
        E={t:eq(t,k) for t in CF}
        bad=[(a,b) for a in CF for b in CF if a!=b and E[a] and not E[b] and all(x<=y for x,y in zip(CF[a],CF[b]))]
        if bad: nonmono.append((k,{t:D[t][k][1] for t in CF}))
        if E['ON'] and not E['A3']:
            s=('133' if not E['33'] else '')+('+' if (not E['33'] and not E['37']) else '')+('137' if not E['37'] else '')
            if E['33'] and E['37']: s='either (133 or 137 alone suffices)' if not E['3B'] else 'neither alone (141?)'
            elif not E['33'] and not E['37']: s='133 AND 137 (joint)'
            sig[s].append(k)
    print('   NON-MONOTONE:', len(nonmono))
    for x in nonmono: print('     ',x)
    for s,v in sorted(sig.items()): print(f'   needs {s}: {len(v)}', ' '.join(v[:12]), '...' if len(v)>12 else '')
