import sys, collections
def rows(p):
    d={}
    for ln in open(p):
        ln=ln.rstrip('\n')
        if not ln: continue
        key,rest=ln.split('\t',1)
        f=dict(x.split('=',1) for x in rest.split('\t'))
        d.setdefault(key.split('|',1)[1],[]).append(f)
    return d
def sels(idxk):
    if idxk=='-': return []
    out=[]
    for part in idxk.split(';'):
        pos=part.find(':IDX=')
        head=part[:pos]; rest=part[pos+5:]
        bpos=rest.find(':BRK=')
        ik=rest[:bpos]; brk=rest[bpos+5:]
        mid,ek=head.split(':',1)
        out.append((mid,ek,ik,brk))
    return out
c=collections.Counter(); wit={}
G=rows(sys.argv[1]); O=rows(sys.argv[2]); tag=sys.argv[3]
for span in sorted(set(G)&set(O)):
    for i in range(min(len(G[span]),len(O[span]))):
        gf,of=G[span][i],O[span][i]
        if gf['NAME']==of['NAME']: continue
        gs,os_=sels(gf['IDXK']),sels(of['IDXK'])
        if len(gs)!=len(os_):
            k=('SHAPE-MISMATCH',gf['IDXK'][:40],of['IDXK'][:40],'LVAL=%s/%s'%(gf['LVAL'],of['LVAL']))
            c[k]+=1; wit.setdefault(k,(span,gf['NAME'],of['NAME'])); continue
        diff=False
        for (m,e,ik,gb),(m2,e2,ik2,ob) in zip(gs,os_):
            if gb==ob: continue
            diff=True
            k=(m+'/'+e,'GIDX='+ik,'OIDX='+ik2,
               ('G-EMPTY' if gb=='[]' else 'G-DROP' if gb=='-' else 'G-TEXT')+'|'+
               ('O-EMPTY' if ob=='[]' else 'O-DROP' if ob=='-' else 'O-TEXT'),
               'LVAL=%s'%gf['LVAL'])
            c[k]+=1; wit.setdefault(k,(span,gf['NAME'],of['NAME'],gb,ob))
        if not diff:
            k=('NAME-DIFF-OUTSIDE-BRACKETS','','','','')
            c[k]+=1; wit.setdefault(k,(span,gf['NAME'],of['NAME'],'',''))
print('=== %s  differing-name paired rows by class'%tag)
for k,n in sorted(c.items(), key=lambda x:-x[1]):
    w=wit[k]
    print('%5d  %s'%(n,' '.join(str(x) for x in k if x!='')))
    print('        @%s\n         G=%s\n         O=%s'%(w[0],w[1],w[2]))
