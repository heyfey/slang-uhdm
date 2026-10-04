#!/usr/bin/env python3
# (r11u232) reads the output of drivers/objid on one database (the caller checks the fence).
# tsusers.py <ids> <typespec name>: every typespec of that name: its parent chain and each reference's owner chain
import sys
rows={}
for ln in open(sys.argv[1]):
    f=ln.rstrip('\n').split('\t'); d={'id':f[0],'type':f[1],'name':f[2],'full':f[3],'span':f[4]}
    for x in f[5:]:
        if '=' in x: k,v=x.split('=',1); d[k]=v
    rows[f[0]]=d
refs={}
for r in rows.values():
    if 'A' in r: refs.setdefault(r['A'],[]).append(r['id'])
def up(i,n=6):
    out=[]
    while i in rows and n>0:
        r=rows[i]; out.append(f"{r['type']}:{r['name'] or r['full']}"); i=r.get('P'); n-=1
        if r['type'] in ('module_inst','package','function'): break
    return ' < '.join(out)
for r in rows.values():
    if r['name']==sys.argv[2] and r['type'].endswith('typespec'):
        us=refs.get(r['id'],[])
        print(f"{r['id']} {r['type']} P=[{up(r.get('P'),3)}] users={len(us)}")
        for u in us[:6]: print(f"     <- {up(rows[u].get('P'),5)}")
