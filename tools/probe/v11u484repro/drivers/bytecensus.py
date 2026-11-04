#!/usr/bin/env python3
# bytecensus.py <list> <out> bin1 bin2 ...: per case dir runs each binary (dut.sv --single-unit --nobuiltin),
# records rc + md5; pauses while a sweep/runner is live (quietwait's live()).
import sys, os, subprocess, hashlib, time, concurrent.futures as cf
sys.path.insert(0,'/tmp/v11u484_tools'); 
import importlib.util
spec=importlib.util.spec_from_file_location('qw','/tmp/v11u484_tools/qwlib.py'); qw=importlib.util.module_from_spec(spec); spec.loader.exec_module(qw)
lst=[l.strip() for l in open(sys.argv[1]) if l.strip()]; out=sys.argv[2]; bins=sys.argv[3:]
done=set()
if os.path.exists(out):
    done={l.split()[0] for l in open(out)}
W='/tmp/v11u484_bc'; os.makedirs(W,exist_ok=True)
def one(d):
    res=[d]
    for i,b in enumerate(bins):
        o=f'{W}/{os.getpid()}_{abs(hash(d))}_{i}.uhdm'
        if os.path.exists(o): os.remove(o)
        try:
            r=subprocess.run(['nice','-n','5',b,'dut.sv','--single-unit','--nobuiltin','-o',o],cwd=d,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,timeout=300).returncode
        except subprocess.TimeoutExpired: r='TO'
        h=hashlib.md5(open(o,'rb').read()).hexdigest()[:10] if os.path.exists(o) else 'none'
        if os.path.exists(o): os.remove(o)
        res.append(f'{r}:{h}')
    return ' '.join(res)
todo=[d for d in lst if d not in done]
with open(out,'a') as f, cf.ThreadPoolExecutor(3) as ex:
    for i in range(0,len(todo),30):
        while qw.live():
            time.sleep(30)
        for r in ex.map(one,todo[i:i+30]):
            f.write(r+'\n')
        f.flush()
print('done',flush=True)
