#!/usr/bin/env python3
"""v11u71 per-cell lister: every ELABORATED cont_assign, keyed by the Lhs's
resolved vpiFullName, with the Rhs kind / size / value / decompile.  Span-free
(no line numbers in the key) so it joins across binaries."""
import re,sys
def cells(path):
    out={}
    lines=open(path,errors='replace').read().split('\n')
    # indentation-based walk
    stack=[]  # (indent, kind, name)
    for i,l in enumerate(lines):
        m=re.match(r'^(\s*)\\_(\w+): ?(\([^)]*\))?',l)
        if not m: continue
        ind=len(m.group(1)); kind=m.group(2); nm=(m.group(3) or '').strip('()')
        while stack and stack[-1][0]>=ind: stack.pop()
        stack.append((ind,kind,nm))
        if kind!='cont_assign': continue
        # gather this cont_assign's block
        j=i+1; blk=[]
        while j<len(lines):
            m2=re.match(r'^(\s*)[\\|]',lines[j])
            if not m2 or len(m2.group(1))<=ind: break
            blk.append(lines[j]); j+=1
        b='\n'.join(blk)
        # Lhs name
        lm=re.search(r'\|vpiLhs:\n\s*\\_(\w+): ?\(([^)]*)\)',b)
        lhs=lm.group(2) if lm else '?'
        rm=re.search(r'\|vpiRhs:\n\s*\\_(\w+): ?(\([^)]*\))?',b)
        if not rm: continue
        rk=rm.group(1); rn=(rm.group(2) or '').strip('()')
        # rhs attributes: the lines after vpiRhs at deeper indent
        ri=b.index('|vpiRhs:')
        rest=b[ri:].split('\n')[2:]
        attrs={}
        base=None
        for r in rest:
            mm=re.match(r'^(\s*)\|(vpiSize|vpiDecompile|vpiConstType|UINT|INT|HEX|BIN|OCT|STRING|REAL|vpiName|vpiActual):?(.*)$',r)
            if not mm: 
                if re.match(r'^\s*\\_',r) and base is not None: break
                continue
            if base is None: base=len(mm.group(1))
            if len(mm.group(1))!=base: continue
            attrs[mm.group(2)]=mm.group(3).strip()
        key=lhs
        sig=f"{rk}:{rn}|"+ "|".join(f"{k}={attrs[k]}" for k in sorted(attrs))
        out.setdefault(key,[]).append(sig)
    return {k:sorted(v) for k,v in out.items()}
if __name__=='__main__':
    a=cells(sys.argv[1]); b=cells(sys.argv[2])
    lbl1=sys.argv[3] if len(sys.argv)>3 else 'A'; lbl2=sys.argv[4] if len(sys.argv)>4 else 'B'
    keys=sorted(set(a)|set(b)); diff=0
    for k in keys:
        if a.get(k)!=b.get(k):
            diff+=1
            print(f"DIFF {k}\n   {lbl1}: {a.get(k)}\n   {lbl2}: {b.get(k)}")
    print(f"cells {lbl1}={len(a)} {lbl2}={len(b)} differing={diff}")
