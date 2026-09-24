# probecensus.py <wdA> <wdB> : per probe case whose database bytes differ, strict verdict + per-field counts A vs B
import sys, os, subprocess, re, filecmp
sys.path.insert(0,'/tmp/wt_v11u130pris/scripts')
os.environ.setdefault('STRICT_CMP','/tmp/v11u130_bin/strictcmp')
import check_probe as cp
SC='/tmp/v11u130_bin/strictcmp'
A,B=sys.argv[1],sys.argv[2]
ROOT='/tmp/wt_v11u130pris/tests/probe'
rels=[]
for dp,dn,fn in os.walk(ROOT):
    if 'dut.sv' in fn: rels.append(os.path.relpath(dp,ROOT))
def fields(g,o):
    r=subprocess.run([SC,'--max','0',g,o],capture_output=True,text=True,timeout=1200)
    out=r.stdout+r.stderr; d={}
    for l in out.splitlines():
        if l.startswith('fields:'):
            for kv in l[7:].split():
                if '=' in kv: k,v=kv.split('='); d[k]=int(v)
            if 'diverged' in l: d['DIVERGED']=1
    v=[l for l in out.splitlines() if l.startswith('STRICT_')]
    return (v[-1] if v else '?'), d
tot={}; nd=0; miss=0
for rel in sorted(rels):
    fa=os.path.join(A,'probe',rel.replace('/','__')+'.uhdm'); fb=os.path.join(B,'probe',rel.replace('/','__')+'.uhdm')
    if not (os.path.exists(fa) and os.path.exists(fb)): miss+=1; continue
    if filecmp.cmp(fa,fb,shallow=False): continue
    nd+=1
    g=cp.golden(rel,'/tmp/v11u130_scratch_probe',300)[0]
    va,da=fields(g,fa); vb,db=fields(g,fb)
    if va==vb and da==db: cls='bytes-only'
    elif 'STRICT_EQUAL' in vb and 'STRICT_EQUAL' in va: cls='bytes-only'
    elif 'STRICT_EQUAL' in vb: cls='turned'
    elif 'STRICT_EQUAL' in va: cls='WORSE'
    else:
        grow=[k for k in db if k!='objects_differing' and db[k]>da.get(k,0)]
        cls='GROW' if grow else 'fewer'
    tot[cls]=tot.get(cls,0)+1
    print(f'{cls}\t{rel}\t{va} {da}\t->\t{vb} {db}')
print('TOTAL', tot, 'byte-movers', nd, 'missing', miss, 'cases', len(rels))
