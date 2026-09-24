#!/usr/bin/env python3
"""compose.py : 2^3 factorial of the three passes over every corpus row-mode and probe case.
configs: ON(111) 30(011) 31(101) 34(110) Xa(001: 130+131 off) Xb(010: 130+134 off) Xc(100: 131+134 off) A3(000).
bits = (130 on, 131 on, 134 on). Prints: per config strict-equal counts; the rows whose equal-set is NOT monotone
(equal at some config but not at a config with a superset of passes on) -- a cancellation suspect; attribution of
every ON-equal row that is not A3-equal (which passes it needs)."""
import csv, sys, itertools, collections
CF={'ON':(1,1,1),'30':(0,1,1),'31':(1,0,1),'34':(1,1,0),'Xa':(0,0,1),'Xb':(0,1,0),'Xc':(1,0,0),'A3':(0,0,0)}
def load(tag, corp):
    p=f'/tmp/r11u141_wd{tag}/{corp}.csv'; d={}
    for r in csv.DictReader(open(p)):
        k=(r.get('name') or r.get('case'))+(','+r['mode'] if 'mode' in r else '')
        d[k]=(r['status'], r.get('strict',''))
    return d
out=[]
for corp in ('surelog','uhdm2rtlil','probe'):
    D={t:load(t,corp) for t in CF}
    keys=set(D['ON'])
    for t in CF: assert set(D[t])==keys, (corp,t,len(keys^set(D[t])))
    eq=lambda t,k: D[t][k][0] in ('CMP_EQUAL','EQUAL')
    je=lambda t,k: D[t][k][0] in ('CMP_EQUAL','EQUAL','STRICT_NOTEQUAL')
    cnt={t:sum(eq(t,k) for k in keys) for t in CF}
    print(f'== {corp}: rows {len(keys)} strict-equal', ' '.join(f'{t}={cnt[t]}' for t in CF))
    stat=sum(1 for k in keys if len({D[t][k][0] in ('CMP_EQUAL','EQUAL','STRICT_NOTEQUAL') for t in CF})>1)
    print(f'   judge-equal status differs across configs: {stat}')
    nonmono=[]; need=collections.Counter(); needrows=collections.defaultdict(list); strictchg=0
    for k in sorted(keys):
        E={t:eq(t,k) for t in CF}
        if len({D[t][k][1] for t in CF})>1: strictchg+=1
        # monotone: if equal at config a then equal at every config b with bits(b) >= bits(a)
        bad=[(a,b) for a in CF for b in CF if E[a] and not E[b] and all(x<=y for x,y in zip(CF[a],CF[b])) and a!=b]
        if bad: nonmono.append((k,{t:D[t][k][1] for t in CF},bad[:3]))
        if E['ON'] and not E['A3']:
            # minimal pass sets making it equal
            sets=[t for t in CF if E[t]]
            sig=''.join('1' if E[t] else '0' for t in CF)
            need[sig]+=1; needrows[sig].append(k)
    print(f'   rows whose strict cell changes across configs: {strictchg}')
    print(f'   NON-MONOTONE (cancellation suspects): {len(nonmono)}')
    for k,v,b in nonmono: print('     ',k,v,b)
    print('   ON-equal & A3-not rows by equal-signature over', ' '.join(CF), ':')
    for s,n in need.most_common(): print('     ',s,n, ' '.join(needrows[s][:6]), '...' if n>6 else '')
