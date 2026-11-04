# judge.py <pristine runcase lines> <law runcase lines> [categories to list]: verdict movement per case dir
import sys,re
def load(f):
    d={}
    for l in open(f):
        p=l.split()
        if len(p)<6: continue
        key=p[0]; rest=' '.join(p[2:])
        rc=re.search(r' rc=(\d+)',l).group(1); cmp=int(re.search(r'cmp=(\d+)',l).group(1))
        st='STRICT_EQUAL' if 'STRICT_EQUAL' in l else ('STRICT_NOTEQUAL' if 'STRICT_NOTEQUAL' in l else ('NOT_EQUAL' if 'NOT_EQUAL' in l else 'OTHER'))
        sf=re.search(r'STRICT_NOTEQUAL (\S+)',l); sf=sf.group(1) if sf else ''
        dd=int(re.search(r'dd=(\d+)',l).group(1)); slrc=re.search(r'slrc=(\S+)',l).group(1)
        d[key]=(rc,cmp,st,sf,dd,slrc)
    return d
a=load(sys.argv[1]); b=load(sys.argv[2])
rank={'STRICT_EQUAL':3,'STRICT_NOTEQUAL':2,'NOT_EQUAL':1,'OTHER':0}
cats={}
for k in sorted(a):
    if k not in b: continue
    x=a[k]; y=b[k]
    if x[0]!=y[0]: c='RC_MOVED'
    elif rank[y[2]]>rank[x[2]]: c='UP'
    elif rank[y[2]]<rank[x[2]]: c='DOWN'
    elif y[2]=='NOT_EQUAL' and y[1]>x[1]: c='CMP_GREW'
    elif y[2]=='NOT_EQUAL' and y[1]<x[1]: c='CMP_SHRANK'
    elif y[4]>x[4]: c='DD_GREW'
    elif y[4]<x[4]: c='DD_SHRANK'
    else: c='SAME_JUDGED'
    cats.setdefault(c,[]).append((k,x,y))
for c,v in sorted(cats.items()):
    print(c,len(v))
    if c in sys.argv[3:]:
        for k,x,y in v: print('   ',k,x,'->',y)
