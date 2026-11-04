#!/usr/bin/env python3
# elab.py <dumpfile>: one line per elaborated param_assign and cont_assign Rhs
# (value, size, const type, whether a typespec is attached, span)
import sys,re
L=open(sys.argv[1]).read().split('\n')
inelab=False; out=[]
def ind(s): return len(s)-len(s.lstrip(' '))
def section(i):
    base=ind(L[i]); j=i+1; sec=[]
    while j<len(L) and (ind(L[j])>base or not L[j].strip().startswith('|')): 
        if L[j].startswith('\\_weakly'): break
        sec.append(L[j]); j+=1
    return sec,j
def rhsinfo(sec):
    # find the vpiRhs block
    for k,l in enumerate(sec):
        if l.strip()=='|vpiRhs:':
            hdr=sec[k+1].strip(); b=ind(sec[k+1]); vals=[]; ts='-'
            m=re.search(r'line:(\S+), endln:(\S+)',hdr); sp=(m.group(1)+'-'+m.group(2)) if m else 'noloc'
            kind=hdr.split(':')[0].lstrip('\\_')
            for l2 in sec[k+2:]:
                if ind(l2)<=b: break
                if ind(l2)==b+2 and l2.strip().startswith('|'):
                    s=l2.strip()
                    if re.match(r'\|(UINT|INT|HEX|BIN|DEC|OCT|STRING|REAL):',s) or s.startswith('|vpiSize') or s.startswith('|vpiConstType') or s.startswith('|vpiDecompile'):
                        vals.append(s[1:])
                    if s.startswith('|vpiTypespec'): ts='TS'
                    if s.startswith('|vpiActual'): ts='ACT'
            return f"{kind} {sp} {' '.join(vals)} {ts}"
    return 'norhs'
i=0; inst=''
while i<len(L):
    l=L[i]
    if l.startswith('\\_weaklyReferenced'): break
    if l.startswith('|uhdm'): inelab = l.startswith('|uhdmtop')
    m=re.match(r'^(\s*)\\_(module_inst|interface_inst): \S+ \((\S+)\)',l)
    if m: inst=m.group(3) if inelab else ''
    m=re.match(r'^(\s*)\|vpi(ParamAssign|ContAssign):',l)
    if m and inst:
        sec,j=section(i)
        lhs=''
        for k,s in enumerate(sec):
            if s.strip()=='|vpiLhs:': 
                mm=re.search(r'\((\S+)\)',sec[k+1]); lhs=mm.group(1) if mm else sec[k+1].strip()
        out.append(f"{inst} {m.group(2)} {lhs}: {rhsinfo(sec)}")
        i=j; continue
    i+=1
print('\n'.join(out))
