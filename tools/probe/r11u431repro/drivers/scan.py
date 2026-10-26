#!/usr/bin/env python3
# scan.py <uhdm-dump text file> : candidate cells for the r11u431 laws (pristine dump)
import sys,re
L=open(sys.argv[1],errors='replace').read().split('\n')
def ind(s): return len(s)-len(s.lstrip())
out=[]
# design-level parameter names (law 1)
dnames=set()
for i,l in enumerate(L):
    if l=='|vpiParameter:' and i+1<len(L):
        m=re.match(r'\\_parameter: \(([^)]*)\)',L[i+1])
        if m: dnames.add(m.group(1))
def actual_of(i):
    k=ind(L[i])
    for j in range(i+1,min(i+60,len(L))):
        s=L[j]
        if s.strip().startswith('\\_') and ind(s)<=k: return None
        if s.strip()=='|vpiActual:' and ind(s)==k+2: return L[j+1].strip()
    return None
stack=[]  # (indent,label)
for i,l in enumerate(L):
    st=l.strip()
    if not st: continue
    k=ind(l)
    isl=st.startswith('|') and st.endswith(':'); iso=st.startswith('\\_')
    if not (isl or iso): continue
    while stack and (stack[-1][0]>k or (stack[-1][0]==k and not (stack[-1][1].startswith('|') and iso))): stack.pop()
    stack.append((k,st))
    m=re.match(r'\\_ref_obj: \(([^)]*)\)',st)
    if not m: continue
    full=m.group(1); nm=full.split('.')[-1].split('::')[-1]
    labels=[x[1] for x in stack]
    inhc=any(x=='|vpiHighConn:' for x in labels)
    par=labels[-3] if len(labels)>=3 else ''
    rel=labels[-2] if len(labels)>=2 else ''
    act=actual_of(i)
    if inhc and (act is None or act.startswith('\\_parameter')):
        if rel=='|vpiIndex:' and par.startswith('\\_bit_select'):
            out.append(('L3idx',full,act or '-'))
        elif rel=='|vpiOperand:' and par.startswith('\\_operation'):
            out.append(('L4op',full,act or '-'))
    if nm in dnames and not inhc:
        if not (act and act.startswith('\\_parameter: (%s)'%nm)):
            out.append(('L1name',full,act or '-'))
    elif nm in dnames and inhc and not (act and act.startswith('\\_parameter: (%s)'%nm)):
        out.append(('L1hc',full,act or '-'))
# law 5: in a DEFINITION listing (under |uhdmallModules) a cont_assign's
# func_call argument that is a concatenation (op 33) with no typespec and at
# least one non-constant operand
sect=None
st2=[]
for i,l in enumerate(L):
    st=l.strip()
    if not st: continue
    if l.startswith('|uhdm') or l.startswith('\\_weaklyReferenced'): sect=st
    k=ind(l)
    isl=st.startswith('|') and st.endswith(':'); iso=st.startswith('\\_')
    if not (isl or iso): continue
    while st2 and (st2[-1][0]>k or (st2[-1][0]==k and not (st2[-1][1].startswith('|') and iso))): st2.pop()
    st2.append((k,st))
    if sect!='|uhdmallModules:' or not st.startswith('\\_operation'): continue
    labs=[x[1] for x in st2]
    if len(labs)<3 or labs[-2]!='|vpiArgument:' or not labs[-3].startswith('\\_func_call'): continue
    if not any(x.startswith('\\_cont_assign') for x in labs): continue
    op=None; ts=False; nonconst=False
    for t in range(i+1,min(i+400,len(L))):
        q=L[t]
        if q.strip().startswith('\\_') and ind(q)<=k: break
        if ind(q)==k+2 and q.strip().startswith('|vpiOpType:'): op=q.strip()
        if ind(q)==k+2 and q.strip()=='|vpiTypespec:': ts=True
        if ind(q)==k+2 and q.strip().startswith('\\_') and not q.strip().startswith('\\_constant') and L[t-1].strip()=='|vpiOperand:': nonconst=True
    if op=='|vpiOpType:33' and not ts and nonconst:
        out.append(('L5cat',st[:80],labs[-3][:60]))
for o in out: print(*o, sep='\t')
