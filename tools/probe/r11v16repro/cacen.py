import sys,re
# extract, from the uhdmtopModules section, each cont_assign's (span, Rhs payload, strengths, delay, Lhs name)
def parse(path):
    L=open(path,encoding='utf-8',errors='replace').read().split('\n')
    # find uhdmtopModules
    start=None
    for i,l in enumerate(L):
        if l.startswith('|uhdmtopModules:'): start=i; break
    if start is None: start=0
    out=[]
    i=start
    n=len(L)
    while i<n:
        l=L[i]
        m=re.match(r'^(\s*)\\_cont_assign: (.*)$',l)
        if m:
            ind=len(m.group(1)); span=m.group(2).strip()
            # collect the block: lines until indentation <= ind on a \_ or | marker at same level
            j=i+1; blk=[]
            while j<n:
                l2=L[j]
                s2=len(l2)-len(l2.lstrip())
                if l2.strip() and s2<=ind and not l2.lstrip().startswith('|vpi') : break
                if l2.strip() and s2<=ind: break
                blk.append(l2); j+=1
            txt='\n'.join(blk)
            # Lhs name
            lm=re.search(r'\|vpiLhs:\n\s*\\_(\w+): \(([^)]*)\)',txt)
            lhs=lm.group(2) if lm else '?'
            # rhs first object line + key fields
            rm=re.search(r'\|vpiRhs:\n(\s*)\\_(.*)',txt)
            rhs=rm.group(2).strip() if rm else 'NONE'
            after=txt[rm.end():] if rm else ''
            dec=re.search(r'\|vpiDecompile:(.*)',after)
            sz=re.search(r'\|vpiSize:(.*)',after)
            val=re.search(r'\|(BIN|HEX|UINT|INT|OCT|STRING):(.*)',after)
            ct=re.search(r'\|vpiConstType:(.*)',after)
            ts=re.search(r'\\_(\w*typespec): ',after)
            st0=re.search(r'\|vpiStrength0:(\d+)',txt); st1=re.search(r'\|vpiStrength1:(\d+)',txt)
            dl=re.search(r'\|vpiDelay:',txt)
            out.append((span,lhs,rhs,
                        dec.group(1).strip() if dec else '',
                        sz.group(1).strip() if sz else '',
                        (val.group(1)+':'+val.group(2).strip()) if val else '',
                        ct.group(1).strip() if ct else '',
                        ts.group(1) if ts else '',
                        st0.group(1) if st0 else '-', st1.group(1) if st1 else '-',
                        'DLY' if dl else '-'))
            i=j; continue
        i+=1
    return out
for p in sys.argv[1:]:
    print('====',p)
    for r in parse(p):
        print('  |'.join(str(x) for x in r))
