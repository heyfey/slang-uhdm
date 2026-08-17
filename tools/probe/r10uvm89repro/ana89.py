import sys, collections
KNOWN={'constant','ref_obj','operation'}
def rows(p):
    for ln in open(p):
        ln=ln.rstrip('\n')
        if not ln: continue
        key,rest=ln.split('\t',1)
        f=dict(x.split('=',1) for x in rest.split('\t'))
        yield key.split('|',1)[1], f
def sels(idxk):
    if idxk=='-': return []
    out=[]
    for part in idxk.split(';'):
        # form: MID|TRAIL:<elemkind>:IDX=<k,k>:BRK=<text>
        pos=part.find(':IDX=')
        head=part[:pos]; rest=part[pos+5:]
        bpos=rest.find(':BRK=')
        ik=rest[:bpos]; brk=rest[bpos+5:]
        mid,ek=head.split(':',1)
        out.append((mid,ek,ik,brk))
    return out
c=collections.Counter(); wit={}
for p in sys.argv[1:]:
    for span,f in rows(p):
        for mid,ek,ik,brk in sels(f['IDXK']):
            ks=set(ik.split(','))
            if ks<=KNOWN: continue     # decompileHelper renders these as themselves
            k=(mid,ek,ik,'EMPTY' if brk=='[]' else ('DROPPED' if brk=='-' else 'TEXT'),'LVAL='+f['LVAL'])
            c[k]+=1
            wit.setdefault(k,(span,f['NAME'],brk,f['SITE']))
for k,n in sorted(c.items(), key=lambda x:-x[1]):
    print('%5d  %-6s %-20s IDX=%-28s %-8s %-7s  %s  NAME=%s BRK=%s' % (n,k[0],k[1],k[2],k[3],k[4],wit[k][0],wit[k][1],wit[k][2]))
