import sys, re
# Census: for every object reached via |vpiReturn:, record
#   key   = the return var's parenthesised name (= the function fullname)
#   value = kind+name of its ref_typespec's vpiActual
def parse(fn):
    out={}
    with open(fn, errors='replace') as f:
        lines=[l.rstrip('\n') for l in f]
    n=len(lines)
    for i,l in enumerate(lines):
        s=l.lstrip(' ')
        if not s.startswith('|vpiReturn:'): continue
        ind=len(l)-len(s)
        # the return var object line
        j=i+1
        if j>=n: continue
        vl=lines[j]; vs=vl.lstrip(' ')
        if not vs.startswith('\\_'): continue
        m=re.match(r'\\_([a-z_]+): \(([^)]*)\)', vs)
        if not m:
            m2=re.match(r'\\_([a-z_]+): ', vs)
            key=(m2.group(1) if m2 else '?','')
        else:
            key=(m.group(1), m.group(2))
        # scan children of the var (indent ind+2) for |vpiTypespec:
        k=j+1; val='<none>'
        while k<n:
            cl=lines[k]; cs=cl.lstrip(' '); ci=len(cl)-len(cs)
            if ci<=ind: break
            if ci==ind+2 and cs.startswith('|vpiTypespec:'):
                # ref_typespec at ind+2, its vpiActual at ind+4
                p=k+2
                while p<n:
                    pl=lines[p]; ps=pl.lstrip(' '); pi=len(pl)-len(ps)
                    if pi<=ind+2: break
                    if pi==ind+4 and ps.startswith('|vpiActual:'):
                        al=lines[p+1].lstrip(' ')
                        val=re.sub(r', line:.*','',re.sub(r', file:.*','',al))[2:]
                        break
                    p+=1
                break
            k+=1
        out.setdefault(key,[]).append(val)
    return out
a=parse(sys.argv[1])
for k in sorted(a, key=lambda x:(x[1],x[0])):
    for v in sorted(a[k]):
        print(f"{k[0]}\t{k[1]}\t{v}")
