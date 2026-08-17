#!/usr/bin/env python3
"""vrgg1 — elab cont_assign reader keyed by the hier_path/ref Lhs NAME.
Prints the Rhs kind + located-ness + all constant fields.  usage: vca.py <dump>"""
import re, sys, collections
def ind(l): return len(l)-len(l.lstrip(' '))
def kids(L,i,hi):
    d=ind(L[i]); j=i+1; o=[]
    while j<hi:
        if not L[j].strip(): j+=1; continue
        if ind(L[j])<=d: break
        if ind(L[j])==d+2: o.append(j)
        j+=1
    return o,j
def kind(l):
    m=re.search(r'\\_(\w+):',l); return m.group(1) if m else '?'
def nm(l):
    m=re.search(r'\\_\w+:\s*\(([^)]*)\)',l); return m.group(1) if m else ''
def loc(l):
    m=re.search(r'line:(\d+:\d+)',l); return m.group(1) if m else 'NOLOC'
def desc(L,i,hi):
    k=kind(L[i])
    if k!='constant': return '<%s>%s @%s'%(k,('('+nm(L[i])+')') if nm(L[i]) else '',loc(L[i]))
    ks,_=kids(L,i,hi); f={}
    for x in ks:
        t=L[x].strip()
        m=re.match(r'^\|((?:BIN|HEX|OCT|DEC|INT|UINT|STRING|REAL|SCAL):\S*)$',t)
        if m: f['val']=m.group(1)
        elif t.startswith('|vpiConstType:'): f['ct']=t.split(':',1)[1]
        elif t.startswith('|vpiSize:'): f['sz']=t.split(':',1)[1]
        elif t.startswith('|vpiDecompile:'): f['dec']=t.split(':',1)[1]
        elif t.startswith('|vpiTypespec:'): f['ts']='Y'
    return 'const ct=%-2s %-12s sz=%-4s dec=%-8s ts=%-1s @%s'%(
        f.get('ct','?'),f.get('val','?'),f.get('sz','?'),f.get('dec',''),f.get('ts','-'),loc(L[i]))
L=open(sys.argv[1],errors='replace').read().splitlines()
fence=next((i for i,l in enumerate(L) if l.startswith('|uhdmtopModules:')),len(L))
view=sys.argv[2] if len(sys.argv)>2 else 'top'
lo,hi=(fence,len(L)) if view=='top' else ((0,fence) if view=='def' else (0,len(L)))
out=collections.OrderedDict(); i=lo
while i<hi:
    if '\\_cont_assign:' not in L[i]: i+=1; continue
    ks,nx=kids(L,i,hi); lname=None; rhs=None
    for j,x in enumerate(ks):
        t=L[x].strip()
        if t=='|vpiLhs:' and j+1<len(ks):
            lx=ks[j+1]; lname=nm(L[lx]) or '<'+kind(L[lx])+'>'
        elif t=='|vpiRhs:' and j+1<len(ks): rhs=desc(L,ks[j+1],hi)
    if lname: out.setdefault('%s @%s'%(lname,loc(L[i])),rhs or '<none>')
    i=nx
for k,v in out.items(): print('%-22s %s'%(k,v))
print('CAs=%d'%len(out))
