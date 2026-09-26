import sys,re
# print (lhs, rhs header, value) for every param_assign block in a uhdm-dump
def parse(f):
    L=open(f).read().split('\n'); out=[]
    for i,l in enumerate(L):
        m=re.match(r'^(\s*)\\_param_assign: ',l)
        if not m: continue
        ind=len(m.group(1))
        # block ends at next line with indent <= ind starting with '\_' or '|'
        j=i+1; blk=[]
        while j<len(L):
            s=L[j]; k=len(s)-len(s.lstrip())
            if k<=ind: break
            blk.append(s); j+=1
        if not blk or not any('|vpiRhs:' in b for b in blk): continue
        rhs='';val='';lhs=''
        for a,b in enumerate(blk):
            if b.strip()=='|vpiRhs:':
                rhs=blk[a+1].strip()
                for c in blk[a+2:a+12]:
                    if re.match(r'\s*\|(UINT|INT|BIN|HEX|DEC|STRING|REAL):',c): val=c.strip(); break
            if b.strip()=='|vpiLhs:': lhs=blk[a+1].strip()
        out.append((lhs,re.sub(r'id:\d+,? ?','',rhs),val))
    return out
for x in parse(sys.argv[1]): print(' | '.join(x))
