#!/usr/bin/env python3
"""a-priori source scan for the § unsizedBasedParamRhsSize106 declaration shape:
an UNTYPED, UNRANGED, non-explicitly-signed parameter/localparam whose default
is an UNSIZED BASED literal ('b/'o/'h/'d, optional s), excluding 'b0/'b1."""
import os, re, sys
PAT = re.compile(r"\b(parameter|localparam)\s+([A-Za-z_]\w*)\s*=\s*('[sS]?[bBoOhHdD][0-9a-fA-FxXzZ_?]+)")
def hits(path):
    out=[]
    try: txt=open(path, errors='replace').read()
    except Exception: return out
    for m in PAT.finditer(txt):
        lit=m.group(3)
        if re.fullmatch(r"'[bB][01]", lit): continue
        ln=txt.count('\n',0,m.start())+1
        out.append((ln, m.group(2), lit))
    return out
roots=sys.argv[1:]
tot=0; files=0
for root in roots:
    for dp,dn,fn in os.walk(root):
        for f in fn:
            if not f.endswith(('.sv','.v','.svh','.vh')): continue
            p=os.path.join(dp,f)
            h=hits(p)
            if h:
                files+=1; tot+=len(h)
                print(f'{p}: {len(h)}  ' + ' '.join(f'{l}:{n}={v}' for l,n,v in h[:6]))
print(f'-- FILES={files} HITS={tot}')
