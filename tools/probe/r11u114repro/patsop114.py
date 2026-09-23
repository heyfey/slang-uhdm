import sys,re
# (r11u114) lists each TOP-module param_assign Rhs kind and whether its operation carries a typespec (TS / -).
L=open(sys.argv[1],errors='replace').read().split('\n')
start=[i for i,l in enumerate(L) if l.startswith('|uhdmtopModules')][0]
out=[]
for i in range(start,len(L)):
    if re.match(r'^  \\_param_assign: , line:',L[i]):
        # rhs
        j=i+1
        while j<len(L) and not L[j].startswith('    |vpiRhs:'):
            if re.match(r'^  \S',L[j]) : break
            j+=1
        if j<len(L) and L[j].startswith('    |vpiRhs:'):
            kind=L[j+1].strip().split(':')[0]
            ts = any(L[k].startswith('      |vpiTypespec:') for k in range(j+2,min(j+6,len(L))))
            out.append((L[i].strip(),kind,ts))
for o in out: print(o[0].split('line:')[1], o[1], 'TS' if o[2] else '-')
