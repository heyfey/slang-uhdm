#!/usr/bin/env python3
"""r10v223 verifier — count ref_obj nodes with and without a vpiActual.

usage: refactual223.py <dump> [<dump> ...]
"""
import re,sys
HEAD=re.compile(r'^(\s*)\\_(\w+):')
FIELD=re.compile(r'^(\s*)\|(vpi\w+):\s*$')
def count(p):
    lines=open(p,errors='replace').read().split('\n')
    stack=[]  # (indent, kind)
    n=0; bare=0
    for i,l in enumerate(lines):
        m=HEAD.match(l)
        if m:
            ind=len(m.group(1))
            while stack and stack[-1][0]>=ind: stack.pop()
            stack.append((ind,m.group(2)))
            if m.group(2)=='ref_obj':
                # look ahead for a |vpiActual: at ind+2
                j=i+1; has=False
                while j<len(lines):
                    mh=HEAD.match(lines[j]); mf=FIELD.match(lines[j])
                    if mh and len(mh.group(1))<=ind: break
                    if mf and len(mf.group(1))==ind+2 and mf.group(2)=='vpiActual': has=True; break
                    j+=1
                n+= 1 if has else 0
                bare+= 0 if has else 1
    return n,bare
for p in sys.argv[1:]:
    a,b=count(p); print('%-52s ref_obj_with_actual=%-5d bare=%-5d'%(p,a,b))
