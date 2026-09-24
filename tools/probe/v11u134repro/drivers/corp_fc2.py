import sys; sys.argv=['x']
exec(open('/tmp/v11u134_scr/corp_fc.py').read().split('for corpus in')[0])
mv=[l.rstrip('\n').split('\t') for l in open('/tmp/v11u134_scr/movers.tsv')]
for corpus,mode,name in mv:
    P=rows(f'/tmp/v11u134_wdP/{corpus}.csv'); L=rows(f'/tmp/v11u134_wdL/{corpus}.csv'); k=(name,mode)
    if (P[k]['status'],P[k]['strict'])!=(L[k]['status'],L[k]['strict']): continue
    if L[k]['status']!='STRICT_NOTEQUAL': print('same ',corpus,name,mode,L[k]['status'],L[k]['strict']); continue
    g,op=dbs('/tmp/v11u134_wdP',corpus,*k); _,ol=dbs('/tmp/v11u134_wdL',corpus,*k)
    fp,dp,_=fields(g,op); fl,dl,_=fields(g,ol)
    grow={f:(fp.get(f,0),fl[f]) for f in fl if f!='objects_differing' and fl[f]>fp.get(f,0)}
    shrink={f:(fp[f],fl.get(f,0)) for f in fp if f!='objects_differing' and fl.get(f,0)<fp[f]}
    print(('GROW ' if grow else 'ok   '),corpus,name,mode,L[k]['strict'],grow,shrink,'div:%s->%s'%(dp,dl),flush=True)
