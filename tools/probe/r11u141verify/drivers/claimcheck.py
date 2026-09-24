import csv, collections
CF=['ON','30','31','34','Xa','Xb','Xc','A3']
def load(tag, corp):
    d={}
    for r in csv.DictReader(open(f'/tmp/r11u141_wd{tag}/{corp}.csv')):
        k=(r.get('name') or r.get('case'))+(','+r['mode'] if 'mode' in r else '')
        d[k]=r['status'] in ('CMP_EQUAL','EQUAL')
    return d
D={c:{t:load(t,c) for t in CF} for c in ('surelog','uhdm2rtlil','probe')}
off={'130':'30','131':'31','134':'34'}
res=collections.Counter(); notes=collections.defaultdict(list)
for l in open('/tmp/r11u141_claims.tsv'):
    p,c,k=l.rstrip('\n').split('\t')
    if k not in D[c]['ON']: res[(p,c,'MISSING')]+=1; notes[(p,c,'MISSING')].append(k); continue
    E={t:D[c][t][k] for t in CF}
    sig=''.join('1' if E[t] else '0' for t in CF)
    if not E['ON']: st='NOT-EQUAL-AT-HEAD'
    elif not E[off[p]]: st='THEIRS (falls back with the pass off)'
    elif not E['A3']: st='SHARED (another pass also converts it)'
    else: st='EQUAL-WITHOUT-ALL-THREE'
    res[(p,c,st)]+=1; notes[(p,c,st)].append(f'{k}[{sig}]')
for k in sorted(res): print(k, res[k], ' '.join(notes[k][:8]) if not k[2].startswith('THEIRS') else '')
