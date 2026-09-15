#!/usr/bin/env python3
"""r11u39 SHAPE LISTER — one line per hier_path: its VpiName and the KIND+NAME
of every Path_elems entry, read from an uhdm-dump.  Used on BOTH sides, so a
census zero is always accompanied by the shapes it counted."""
import re, sys
def parse(path):
    L=open(path,errors='replace').read().split('\n')
    out=[]; i=0
    while i<len(L):
        m=re.match(r'^(\s*)(?:\\_)?hier_path: \((.*)\), (?:id:\d+, )?line:', L[i])
        if m:
            ind=len(m.group(1)); nm=m.group(2); j=i+1; elems=[]
            while j<len(L):
                if L[j].strip()=='' : break
                ind2=len(L[j])-len(L[j].lstrip())
                if ind2<=ind: break
                # direct children of the hier_path (indent ind+2) that follow |vpiActual:
                if ind2==ind+2 and L[j].lstrip().startswith('\\_') and L[j-1].strip()=='|vpiActual:':
                    mm=re.match(r'\\_(\w+): \((.*)\), ', L[j].lstrip())
                    if mm:
                        kind=mm.group(1)
                        # find its vpiName / count of vpiIndex or exprs at ind2+2
                        k=j+1; name=None; nidx=0
                        while k<len(L):
                            if L[k].strip()=='': break
                            ind3=len(L[k])-len(L[k].lstrip())
                            if ind3<=ind2: break
                            if ind3==ind2+2:
                                t=L[k].strip()
                                if t.startswith('|vpiName:') and name is None: name=t[9:]
                                if t in ('|vpiIndex:','|vpiExprs:','|Exprs:'): nidx+=1
                            k+=1
                        elems.append('%s[%s]/%d'%(kind,name if name is not None else '-',nidx))
                j+=1
            out.append((nm,elems)); i=j
        else: i+=1
    return out
for f in sys.argv[1:]:
    print('==== '+f)
    for nm,el in sorted(parse(f)):
        print('  %-44s %s'%(nm,' + '.join(el)))
