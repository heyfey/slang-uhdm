import re,sys
rank={'STRICT_EQUAL':3,'STRICT_NOTEQUAL':2,'NOT_EQUAL':1,'NA':0}
def parse(f):
    m=re.match(r'(\w+):rc=(\S+) cmp=(\S+) dist=(\S+) md5=(\S*) \[(\S+)',f)
    return dict(n=m[1],rc=m[2],cmp=m[3],dist=m[4],md5=m[5],v=m[6])
a,b=sys.argv[2],sys.argv[3]
cats={}
for line in open(sys.argv[1]):
    t=line.rstrip('\n').split('\t')
    d={x['n']:x for x in map(parse,t[2:])}
    P,V=d[a],d[b]
    if P['md5']==V['md5']: c='byte-identical'
    elif rank[V['v']]>rank[P['v']]: c=f"{P['v']}->{V['v']}"
    elif rank[V['v']]<rank[P['v']]: c=f"AWAY {P['v']}->{V['v']}"
    else:
        dp,dv=int(P['dist']),int(V['dist'])
        c = 'closer' if dv<dp else ('same-dist-moved' if dv==dp else 'FURTHER-dist')
    if P['rc']!=V['rc']: c+=' RC'
    cats.setdefault(c,[]).append(f"{t[0]}({P['dist']}->{V['dist']})")
for c,l in sorted(cats.items()): print(len(l),c,' '.join(l))
