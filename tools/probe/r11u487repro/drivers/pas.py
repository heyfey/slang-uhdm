#!/usr/bin/env python3
# pas.py <dumpfile>: print the elaborated instances' vpiParamAssign sections (parent lines dropped)
import sys,re
L=open(sys.argv[1]).read().split('\n')
inelab=False; out=[]; i=0
while i<len(L):
    l=L[i]
    if l.startswith('\\_weaklyReferenced'): break
    if re.match(r'^  \|vpi(Module|Interface):',l): inelab=True
    m=re.match(r'^(\s*)\|vpiParamAssign:',l)
    if inelab and m and len(m.group(1))==4:
        ind=len(m.group(1)); j=i+1; sec=[]
        while j<len(L):
            k=re.match(r'^(\s*)',L[j]).group(1)
            if len(k)<=ind and L[j].strip().startswith('|'): break
            sec.append(L[j]); j+=1
        k=0
        while k<len(sec):
            if sec[k].strip()=='|vpiParent:': k+=2; continue
            out.append(sec[k][4:]); k+=1
        out.append('--'); i=j; continue
    i+=1
print('\n'.join(out))
