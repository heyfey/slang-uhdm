import sys,re
def load(f):
    d={}
    for l in open(f):
        p=l.split()
        if len(p)<4: continue
        k=p[0]; kv=dict(x.split('=',1) for x in p if '=' in x)
        m=re.search(r'cmp=\d+ (\S+)',l); kv['v']=m.group(1) if m else '?'
        d[k]=kv
    return d
a=load(sys.argv[1]); b=load(sys.argv[2])
rank={'STRICT_EQUAL':3,'STRICT_NOTEQUAL':2,'NOT_EQUAL':1}
cnt={}
for k in sorted(a):
    if k not in b: print('MISSING',k); continue
    x,y=a[k],b[k]
    def i(v):
        try: return int(v)
        except: return -1
    ru,rv=rank.get(x['v'],0),rank.get(y['v'],0)
    tag='same'
    if x.get('rc')!=y.get('rc'): tag='RCMOVE'
    elif rv>ru: tag='UP'
    elif rv<ru: tag='DOWN'
    elif i(y.get('cmp'))>i(x.get('cmp')) : tag='CMPGROW'
    elif i(y.get('dd'))>i(x.get('dd')) or i(y.get('oc'))>i(x.get('oc')): tag='DISTGROW'
    elif i(y.get('dd'))<i(x.get('dd')) or i(y.get('oc'))<i(x.get('oc')) or i(y.get('cmp'))<i(x.get('cmp')): tag='closer'
    cnt[tag]=cnt.get(tag,0)+1
    if tag not in ('same','closer','UP') or len(sys.argv)>3:
        print(tag,k,'|',x.get('rc'),x['v'],'cmp',x.get('cmp'),'dd',x.get('dd'),'oc',x.get('oc'),'ic',x.get('ic'),'->',y.get('rc'),y['v'],'cmp',y.get('cmp'),'dd',y.get('dd'),'oc',y.get('oc'),'ic',y.get('ic'))
print(cnt)
