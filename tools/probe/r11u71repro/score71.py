import os,sys,subprocess,json
sys.path.insert(0,'/tmp')
import importlib.util
spec=importlib.util.spec_from_file_location("sh",os.path.join(os.path.dirname(os.path.abspath(__file__)),"shapes71.py"))
sh=importlib.util.module_from_spec(spec); spec.loader.exec_module(sh)
os.environ['NOSPAN']='1'
def sig(v):
    if not v or not v['rhs']: return 'NONE'
    r=v['rhs']
    return f"{r.get('kind')} {r.get('value')} sz={r.get('vpiSize')} ct={r.get('vpiConstType')} dec={r.get('vpiDecompile')} nm={r.get('name')}"
grid=sys.argv[1]
tot={'FIXED':0,'BROKEN':0,'STILL':0,'MOVED-STILL-WRONG':0}
for a in sorted(os.listdir(grid)):
    d=os.path.join(grid,a)
    fs=[os.path.join(d,f) for f in ('gold.pat.dump','ours.pris.dump','ours.pat.dump')]
    if not all(os.path.exists(f) for f in fs): continue
    g=dict(sh.flat(fs[0])); p=dict(sh.flat(fs[1])); q=dict(sh.flat(fs[2]))
    rows=[]
    for k in sorted(set(g)|set(p)|set(q), key=lambda t: tuple(map(str,t))):
        gs,ps,qs=sig(g.get(k)),sig(p.get(k)),sig(q.get(k))
        if ps==qs and gs==qs: continue
        if ps!=gs and qs==gs: tot['FIXED']+=1; rows.append(('FIXED',k,gs,ps,qs))
        elif ps==gs and qs!=gs: tot['BROKEN']+=1; rows.append(('BROKEN',k,gs,ps,qs))
        elif ps==qs: tot['STILL']+=1; rows.append(('STILL',k,gs,ps,qs))
        else: tot['MOVED-STILL-WRONG']+=1; rows.append(('MOVED-STILL-WRONG',k,gs,ps,qs))
    if rows:
        print('###',a)
        for t,k,gs,ps,qs in rows:
            print(f'  {t} {"|".join(map(str,k))}')
            print(f'     G: {gs}')
            print(f'     P: {ps}')
            print(f'     Q: {qs}')
print('TOTALS',tot)
