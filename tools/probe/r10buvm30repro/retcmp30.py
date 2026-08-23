"""Print each TOP-view return_stmt's condition subtree, compactly, for a dump."""
import sys
import os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cen30 import parse, loc

def render(objs, o, depth=0, out=None):
    f=o['fields']
    bits=[o['kind'], loc(o)]
    for k in ('vpiOpType','vpiName','vpiDecompile','vpiSize','vpiConstType','INT','UINT','REAL'):
        if k in f: bits.append('%s=%s'%(k,f[k][0]))
    par = 'par=' + (objs[o['parent']]['kind']+'@'+loc(objs[o['parent']]) if 'vpiParent' in f and o['parent'] is not None else '-')
    if 'vpiParent' not in f: par='par=NONE'
    ts = 'ts=YES' if 'vpiTypespec' in f else 'ts=-'
    out.append('  '*depth + ' '.join(bits) + ' ' + par + ' ' + ts)
    for k in o['kids']:
        c=objs[k]
        if c['slot'] in ('vpiParent',): continue
        if c['slot'] in ('vpiOperand','vpiIndex','vpiCondition','vpiArgument','vpiExpr','vpiActual','vpiTypespec'):
            if c['slot']=='vpiTypespec': continue
            render(objs,c,depth+1,out)
    return out

objs=parse(sys.argv[1]); top=int(sys.argv[2])
res=[]
for o in objs:
    if o['kind']=='return_stmt' and o['line']>top:
        conds=[objs[k] for k in o['kids'] if objs[k]['slot']=='vpiCondition']
        for c in conds:
            res.append((loc(o), '\n'.join(render(objs,c,1,[]))))
seen=set()
for l,body in res:
    if (l,body) in seen: continue
    seen.add((l,body))
    print('RET @'+l); print(body)
