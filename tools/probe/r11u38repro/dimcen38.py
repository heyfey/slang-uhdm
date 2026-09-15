import re,sys
def indent(l):
    n=0
    while n<len(l) and l[n]==' ': n+=1
    return n
def parse(path):
    raw=[l.rstrip('\n') for l in open(path,errors='replace')]
    L=[(indent(l),l.strip()) for l in raw if l.strip()]
    n=len(L); rows=[]
    # walk array_var / array_net / logic_var(with packed range) holders
    i=0
    while i<n:
        ind,txt=L[i]
        m=re.match(r'\\_(array_var|array_net|logic_var|logic_net|logic_typespec|array_typespec):\s*\(?([^),]*)\)?',txt)
        if m:
            kind=m.group(1); nm=m.group(2)
            # gather the sub-block
            j=i+1; blk=[]
            while j<n and L[j][0]>ind:
                blk.append(L[j]); j+=1
            # find constants under ranges
            shp=[]
            for bi,(bind,bt) in enumerate(blk):
                if bt.startswith('\\_constant:'):
                    f={}
                    k=bi+1
                    while k<len(blk) and blk[k][0]>bind:
                        if blk[k][0]==bind+2 and blk[k][1].startswith('|'):
                            ff=blk[k][1][1:]
                            if ':' in ff:
                                a,b=ff.split(':',1)
                                f.setdefault(a,b)
                        k+=1
                    val=None
                    for t in ('UINT','INT','BIN','HEX','DEC','OCT'):
                        if t in f: val=t+':'+f[t]; break
                    # typespec actual kind
                    ts=None
                    k=bi+1
                    while k<len(blk) and blk[k][0]>bind:
                        if blk[k][1].startswith('\\_') and 'typespec' in blk[k][1] and 'ref_typespec' not in blk[k][1]:
                            ts=blk[k][1].split(':')[0].lstrip('\\_'); break
                        k+=1
                    loc=re.search(r'line:(\d+:\d+), endln:(\d+:\d+)',bt)
                    shp.append('%s ct%s sz%s dec=%s ts=%s @%s'%(val,f.get('vpiConstType'),f.get('vpiSize'),f.get('vpiDecompile'),ts,loc.group(1) if loc else '-'))
            if shp and nm:
                rows.append((kind+' '+nm,' | '.join(shp)))
            i=j; continue
        i+=1
    d={}
    for k,v in rows: d.setdefault(k,[]).append(v)
    return d
if __name__ == '__main__':
    g=parse(sys.argv[1])
    o=parse(sys.argv[2]) if len(sys.argv)>2 else None
    if o is None:
        for k in sorted(g): print('%-34s %s'%(k,g[k]))
    else:
        same=diff=0
        for k in sorted(set(g)|set(o)):
            gv=sorted(g.get(k,[])); ov=sorted(o.get(k,[]))
            if gv==ov: same+=1
            else:
                diff+=1
                print('DIFF %-30s'%k)
                for x in gv: print('   G %s'%x)
                for x in ov: print('   O %s'%x)
        print('same=%d diff=%d'%(same,diff))
