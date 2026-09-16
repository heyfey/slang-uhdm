import re,sys
def load(p):
    d={}; k=None
    for ln in open(p):
        m=re.match(r'^(SAME|DIFF) (\S+)\s+(\S+)\s+(.*)$', ln.rstrip())
        if m: k=(m.group(2),m.group(3)); d[k]=[m.group(1), m.group(4), '']
        elif ln.startswith('     ') and k: d[k][2]=ln.strip()
    return d
P=load(sys.argv[1]); L=load(sys.argv[2])
mw=aw=fx=0; names=[]
for k in sorted(set(P)|set(L)):
    p=P.get(k); l=L.get(k)
    if p[0]==l[0] and p[1]==l[1] and p[2]==l[2]: continue
    if p[0]=='DIFF' and l[0]=='SAME': tag='FIXED'; fx+=1
    elif p[0]=='SAME' and l[0]=='DIFF':
        tag='MOVED-WRONG'; mw+=1
        print('MOVED-WRONG %s %s\n  pris %s %s\n  law  %s %s'%(k[0],k[1],p[1],p[2],l[1],l[2]))
    else:
        tag='WRONG->WRONG'; aw+=1
        print('WRONG->WRONG %s %s\n  pris %s %s\n  law  %s %s'%(k[0],k[1],p[1],p[2],l[1],l[2]))
    names.append((tag,k))
print('%s: FIXED %d MOVED-WRONG %d WRONG->WRONG %d  [%s]' % (sys.argv[3], fx,mw,aw, ' '.join(sorted(set(k[0] for t,k in names if t=='FIXED')))))
