# v11u298 ctlsum3.py <controls3 out>: movers law and fix vs pristine, STRICT_EQUAL entries/exits, exit-code changes, fix-vs-law lines.
import collections, sys
rows=collections.defaultdict(dict)
for l in open(sys.argv[1]):
    w=l.split(); rows[(w[0],w[1])][w[2]]=' '.join(w[3:])
md=lambda x:x.split('md5=')[1] if 'md5=' in x else x
st=lambda x:x.rsplit(' md5',1)[0]
n=len(rows); c=collections.Counter()
for k in sorted(rows):
    r=rows[k]
    for a in ('law','fix'):
        if md(r['pristine'])!=md(r[a]):
            c[a+'_movers']+=1
            if 'STRICT_EQUAL' in r[a] and 'STRICT_EQUAL' not in r['pristine']: c[a+'_enter']+=1
            if 'STRICT_EQUAL' in r['pristine'] and 'STRICT_EQUAL' not in r[a]: c[a+'_leave']+=1
            if r['pristine'].split()[0]!=r[a].split()[0]: c[a+'_rc']+=1
            if a=='law' or md(r['fix'])!=md(r['law']): print('MOVER',k[0],k[1]+':',a,'|',st(r['pristine']),'->',st(r[a]))
    if md(r['fix'])!=md(r['law']): c['fix_vs_law']+=1; print('FIXLAW',k[0],k[1],'|',st(r['law']),'->',st(r['fix']))
print('case-views',n,dict(c))
