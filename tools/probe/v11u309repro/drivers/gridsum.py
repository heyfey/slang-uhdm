#!/usr/bin/env python3
# v11u309 gridsum.py <grid.txt>: summarise a grid written by tools/probe/r11u309repro/drivers/grid.sh (P, L, OFF and one line per switch per case-view): movers, entering/leaving STRICT_EQUAL, exit-code changes, the single switch restoring pristine bytes. Reads only the grid text (no database, no source).
import collections,sys
rows=collections.defaultdict(dict)
for l in open(sys.argv[1]):
    p=l.split(); cfg=p[0]; case=p[1]
    d=dict(x.split('=',1) for x in p[3:] if '=' in x); d.setdefault('md5','NONE'); d.setdefault('rc','?'); d.setdefault('cmp','?'); d.setdefault('cmplines','?'); d.setdefault('strict','?')
    rows[case][cfg]=d
mov=ent=leave=rcch=offbad=0; single=collections.Counter(); multi=[]
def eq(d): return d['strict'].startswith('STRICT_EQUAL') and d['cmp']=='0'
for c in sorted(rows):
    r=rows[c]; P,L=r['P'],r['L']
    if r['OFF']['md5']!=P['md5']: offbad+=1; print('OFFBAD',c)
    if P['rc']!=L['rc']: rcch+=1; print('RCCH',c,P['rc'],L['rc'])
    if P['md5']==L['md5']:
        print('same',c,P['cmplines'],P['strict'],'rc',P['rc']); continue
    mov+=1
    pe,le=eq(P),eq(L)
    ent+= (le and not pe); leave+=(pe and not le)
    rest=[k for k in r if k.startswith('R11') and r[k]['md5']==P['md5']]
    tag='ENTER' if le and not pe else ('LEAVE' if pe and not le else 'move')
    print(tag,c,'P:',P['cmplines'],P['strict'],'L:',L['cmplines'],L['strict'],'rc',P['rc'],L['rc'],'restore',','.join(x.replace('R11U309_','') for x in rest) or '-')
    if len(rest)==1: single[rest[0]]+=1
    else: multi.append(c)
print('views',len(rows),'moving',mov,'enter',ent,'leave',leave,'rcch',rcch,'offbad',offbad)
print(single, 'multi',len(multi))
