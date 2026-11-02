# targeted pristine byte check: rows whose sources mention import/export, fence-filtered first
import os, re, subprocess, sys, hashlib, glob
fenced=set(open('/tmp/v11u471_fenced.txt').read().split())
corpus, mode, root = sys.argv[1], sys.argv[2], sys.argv[3]
wd=f'/tmp/v11u471_sw/{corpus}/{mode}'
out=open(f'/tmp/v11u471_pbc_{corpus}_{mode}.txt','w')
n=cand=same=diff=0
for d in sorted(os.listdir(wd)):
    name=d.rsplit('-',1)[0]
    if name in fenced or any(f in d for f in fenced): continue
    db=os.path.join(wd,d,'slang.uhdm'); cm=os.path.join(wd,d,'cmds.txt')
    if not os.path.isfile(db) or not os.path.isfile(cm): continue
    tdir=os.path.join(root,name)
    if not os.path.isdir(tdir): continue
    srcs=[p for p in glob.glob(tdir+'/**/*',recursive=True) if re.search(r'\.(s?v|svh|vh|sv)$',p)]
    hit=False
    for s in srcs:
        try:
            if re.search(r'\b(import|export)\b',open(s,errors='ignore').read()): hit=True;break
        except: pass
    n+=1
    if not hit: continue
    cand+=1
    line=[l for l in open(cm) if l.startswith('slang:')][0].split(None,1)[1].strip()
    args=line.split()[1:]
    i=args.index('-o'); o=f'/tmp/v11u471_pbc_out/{corpus}_{mode}_{d}.uhdm'
    os.makedirs('/tmp/v11u471_pbc_out',exist_ok=True)
    if os.path.exists(o): os.remove(o)
    args[i+1]=o
    rc=subprocess.run(['/tmp/v11u471_bin/pristine']+args,cwd=tdir,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,timeout=600).returncode
    a=open(db,'rb').read(); b=open(o,'rb').read() if os.path.exists(o) else b''
    if a==b: same+=1
    else: diff+=1; out.write(f'MOVER {d} rc={rc}\n')
    os.remove(o) if os.path.exists(o) else None
out.write(f'rows={n} import_candidates={cand} same={same} differ={diff}\n')
print(f'{corpus}/{mode}: rows={n} import_candidates={cand} same={same} differ={diff}')
