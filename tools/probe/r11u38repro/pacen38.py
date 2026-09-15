import re,sys
# Structured uhdm-dump reader: indentation-based tree walk.
# Emits one row per param_assign:  <holder-path>.<Lhs name>  <Rhs shape>
def indent(l):
    n=0
    while n<len(l) and l[n]==' ': n+=1
    return n
def parse(path):
    """One row per param_assign, KEYED BY LISTING VIEW as well as by name.

    The view is part of the key because the two listings have two producers:
    `uhdmallModules` / `uhdmallPackages` are written before elaboration and
    `uhdmtopModules` / `uhdmtopPackages` after it, and a law that claims one of
    them must not be scored against a multiset that pools both.  Pooling made
    five cells of `r10earl52repro/v1_earl52.sv` read MOVED-WRONG when the
    definition entry had in fact landed exactly on golden and the elaborated
    entry had not moved at all.
    """
    raw=[l.rstrip('\n') for l in open(path,errors='replace')]
    lines=[(indent(l), l.strip()) for l in raw if l.strip()]
    rows=[]
    n=len(lines)
    i=0
    view='?'
    while i<n:
        ind,txt=lines[i]
        for _v in ('uhdmallPackages','uhdmtopPackages','uhdmallModules',
                   'uhdmtopModules','uhdmallUdps','uhdmtopUdps'):
            if txt.startswith('|'+_v):
                view=_v
        if txt.startswith('\\_param_assign:'):
            # children: lines with indent > ind until indent <= ind
            j=i+1
            lhs=None; rhs=None
            # find |vpiRhs: / |vpiLhs: at indent ind+2
            while j<n and lines[j][0]>ind:
                ji,jt=lines[j]
                if ji==ind+2 and jt=='|vpiRhs:':
                    # the object line is next
                    k=j+1
                    if k<n:
                        oind=lines[k][0]
                        fields={}
                        kind=lines[k][1]
                        m=k+1
                        while m<n and lines[m][0]>oind:
                            if lines[m][0]==oind+2 and lines[m][1].startswith('|'):
                                f=lines[m][1][1:]
                                if ':' in f:
                                    a,b=f.split(':',1)
                                    if a not in fields: fields[a]=b
                            m+=1
                        rhs=(kind.split(':')[0].lstrip('\\_'),fields)
                if ji==ind+2 and jt=='|vpiLhs:':
                    k=j+1
                    if k<n:
                        mm=re.search(r'\(([^)]*)\)',lines[k][1])
                        if mm: lhs=mm.group(1)
                j+=1
            if lhs:
                kind,f=rhs if rhs else ('<none>',{})
                val=None
                for t in ('UINT','INT','BIN','HEX','DEC','OCT','STRING','REAL'):
                    if t in f: val=t+':'+f[t]; break
                rows.append((view+' '+lhs,'%s %s ct%s sz%s dec=%s'%(kind,val,f.get('vpiConstType'),f.get('vpiSize'),f.get('vpiDecompile'))))
            i=j; continue
        i+=1
    d={}
    for k,v in rows: d.setdefault(k,[]).append(v)
    return d
if __name__ == '__main__':
    g=parse(sys.argv[1]); o=parse(sys.argv[2])
    only=sys.argv[3] if len(sys.argv)>3 else None
    same=diff=0
    for k in sorted(set(g)|set(o)):
        if only and only not in k: continue
        gv=sorted(g.get(k,[])); ov=sorted(o.get(k,[]))
        if gv==ov: same+=1; print('SAME %-22s %s'%(k,gv))
        else:
            diff+=1
            print('DIFF %-22s G=%s'%(k,gv)); print('     %-22s O=%s'%('',ov))
    print('same=%d diff=%d'%(same,diff))
