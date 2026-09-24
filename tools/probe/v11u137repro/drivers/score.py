#!/usr/bin/env python3
# score.py <cases root> <outtsv> [--elab] [--env K=V ...] [--only regex]
import os, sys, subprocess, re, concurrent.futures as cf, hashlib
env = dict(os.environ)
SURELOG=env['SURELOG']; CMP=env['UHDM_CMP']; SC=env['STRICT_CMP']
BINS={'P':env['PRIS'],'L':env['LAW']}
root=sys.argv[1]; out=sys.argv[2]; elab='--elab' in sys.argv
extra={}; only=None; bins=['P','L']
a=sys.argv[3:]
for i,x in enumerate(a):
    if x=='--env': k,v=a[i+1].split('=',1); extra[k]=v
    if x=='--only': only=re.compile(a[i+1])
    if x=='--bins': bins=a[i+1].split(',')
W='/tmp/v11u137_cw'+('E' if elab else '')
def one(case):
    d=os.path.join(root,case); key=case
    w=os.path.join(W,key); os.makedirs(w,exist_ok=True)
    h=hashlib.md5(b''.join(open(os.path.join(d,f),'rb').read() for f in sorted(os.listdir(d)) if os.path.isfile(os.path.join(d,f)))).hexdigest()
    g=os.path.join(w,'golden.uhdm')
    if not (os.path.exists(g) and open(os.path.join(w,'hash')).read()==h if os.path.exists(os.path.join(w,'hash')) else False):
        subprocess.run(['rm','-rf',os.path.join(w,'sl'),g])
        fl=['-parse']+(['-elabuhdm'] if elab else [])+['-nobuiltin','-nocache','-sv','dut.sv','-mt','0','-mp','0','-o',os.path.join(w,'sl')]
        subprocess.run([SURELOG]+fl,cwd=d,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,timeout=300)
        s=os.path.join(w,'sl','slpp_all','surelog.uhdm')
        if os.path.exists(s): os.rename(s,g)
        open(os.path.join(w,'hash'),'w').write(h)
    res=[case]
    for t in bins:
        o=os.path.join(w,t+'.uhdm')
        if os.path.exists(o): os.remove(o)
        e=dict(env); e.update(extra)
        r=subprocess.run([BINS[t],'dut.sv','--single-unit','--nobuiltin']+(['--elabuhdm'] if elab else [])+['-o',o],cwd=d,env=e,stdout=subprocess.DEVNULL,stderr=subprocess.PIPE,timeout=300)
        if not os.path.exists(g):
            res.append(f'{t}:rc={r.returncode} NOGOLDEN'); continue
        c=subprocess.run([CMP,g,o],capture_output=True,text=True)
        n=len((c.stdout+c.stderr).splitlines())
        s=subprocess.run([SC,'--max','40','--dump-a',os.path.join(w,t+'.grec'),'--dump-b',os.path.join(w,t+'.rec'),g,o],capture_output=True,text=True)
        lines=(s.stdout+s.stderr).splitlines()
        fl=[x for x in lines if x.startswith('fields')]
        last=[x for x in lines if 'STRICT_' in x or 'NOT_EQUAL' in x]
        v=last[-1] if last else (lines[-1] if lines else '?')
        v=re.sub(r'\s+',' ',v)
        res.append(f'{t}:rc={r.returncode} cmp={n} {v} {fl[0] if fl else ""}')
        open(os.path.join(w,t+'.strict'),'w').write(s.stdout+s.stderr)
    return res
cases=sorted(x for x in os.listdir(root) if os.path.isdir(os.path.join(root,x)) and (not only or only.search(x)))
with cf.ThreadPoolExecutor(3) as ex:
    rows=list(ex.map(one,cases))
with open(out,'w') as f:
    for r in rows: f.write('\t'.join(r)+'\n')
for r in rows: print('\t'.join(r))
