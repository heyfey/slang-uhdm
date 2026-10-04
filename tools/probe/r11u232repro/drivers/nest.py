#!/usr/bin/env python3
# (r11u232) reads the output of drivers/objid on one database (the caller checks the fence).
# nest.py <ids> <struct name> <member>: for every struct_typespec <name>, who references it (the chain up to a named
# object), and its <member>'s ref actual (+ that actual's parent), and the member's AV.
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
def up(i):
    out=[]; seen=0
    while i in rows and seen<8:
        r=rows[i]; out.append(f"{r['type']}:{r['name'] or r['full']}"); i=r.get('P'); seen+=1
        if r['type'] in ('module_inst','package','function'): break
    return ' < '.join(out)
for r in rows.values():
    if r['type']=='struct_typespec' and r['name']==sys.argv[2]:
        mem=[m for m in rows.values() if m['type']=='typespec_member' and m.get('P')==r['id'] and m['name']==sys.argv[3]]
        users=[up(x) for x in refs.get(r['id'],[])]
        for m in mem:
            ref=rows.get(m.get('T'),{}); act=rows.get(ref.get('A'),{})
            print(f"{r['id']} P={up(r.get('P'))} | users={len(users)} {users[:2]} | {sys.argv[3]}->{act.get('id')} P={act.get('P')} AV={m.get('AV')}")
