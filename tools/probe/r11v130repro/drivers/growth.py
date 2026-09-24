import re,sys
def fields(s):
    m=re.search(r'\{([^}]*)\}',s); d={}
    if m and m.group(1):
        for kv in m.group(1).split():
            if '=' in kv:
                k,v=kv.split('=',1)
                try: d[k]=int(v)
                except: pass
    cm=int(re.search(r'cmp=(\d+)',s).group(1))
    return d,cm
a,b=sys.argv[2],sys.argv[3]
for l in open(sys.argv[1]):
    parts=l.strip().split(' | ')
    d={p[0]:p for p in parts[1:]}
    fp,cp=fields(d[a]); fl,cl=fields(d[b])
    grow=[k for k in fl if fl[k]>fp.get(k,0) and k!='objects_differing']
    if cp!=cl or grow or ('STRICT_EQUAL' in d[a] and 'STRICT_EQUAL' not in d[b]) or 'rc=0' not in d[b]:
        print(parts[0], 'cmp',cp,cl,'grow',grow, fp, fl)
