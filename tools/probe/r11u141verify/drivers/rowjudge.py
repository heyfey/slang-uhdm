#!/usr/bin/env python3
"""rowjudge.py <corpus> <mode> <name> <tagP> <tagL> : record-level judge of one sweep row between two sweeps
(strictx dumps; judge.py = walk-aligned field worse; judge2.py = difflib-aligned field worse)."""
import sys, os, glob, re, subprocess, shutil
corp,mode,name,P,L=sys.argv[1:6]
def find(tag):
    ds=[d for d in glob.glob(f'/tmp/r11u141_wd{tag}/{corp}/{mode}/{name}-*') if os.path.exists(d+'/slang.uhdm')]
    ds=[d for d in ds if re.fullmatch(re.escape(name)+r'-[0-9a-f]{8}',os.path.basename(d))]
    return ds[0] if len(ds)==1 else None
dp,dl=find(P),find(L)
if not dp or not dl: print('NOTFOUND',dp,dl); sys.exit()
g=re.search(r'golden cache (?:hit|miss|store)?\s*(\S+?)\)',open(dp+'/cmds.txt').read())
gdir=g.group(1) if g else None
gold=f'{gdir}/golden.uhdm'
if not os.path.exists(gold): print('NOGOLDEN',gdir); sys.exit()
w=f'/tmp/r11u141_rows/{corp}_{mode}_{name}'; os.makedirs(w,exist_ok=True)
for t,d in (('P',dp),('L',dl)):
    shutil.copy(d+'/slang.uhdm',f'{w}/{t}.uhdm')
    for x in ('rec','diffs'):
        if os.path.exists(f'{w}/{t}.{x}'): os.unlink(f'{w}/{t}.{x}')
    subprocess.run(['/tmp/r11u141_bin/strictx','--max','0','--diffs',f'{w}/{t}.diffs','--dump-a',f'{w}/g_{t}.rec','--dump-b',f'{w}/{t}.rec',gold,f'{w}/{t}.uhdm'],capture_output=True)
a=subprocess.run(['python3','/tmp/r11u141_drv/judge.py',w,'P','L'],capture_output=True,text=True).stdout.strip()
n=sum(1 for _ in open(f'{w}/g_P.rec')) if os.path.exists(f'{w}/g_P.rec') else 0
b=subprocess.run(['python3','/tmp/r11u141_drv/unmask.py' if n>50000 else '/tmp/r11u141_drv/judge2.py',w]+([] if n>50000 else ['P','L']),capture_output=True,text=True).stdout.strip().replace('\n',' | ')
print(f'{corp}/{mode}/{name} {P}->{L}: {a[:220]} || {b[:160]}')
