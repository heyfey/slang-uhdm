# a-priori SURELOG-corpus mover prediction: every row whose slang command line
# compiles a file that contains a signing cast, resolved against the row's own
# source dir (recovered from the sha1 the harness puts in the workdir name).
import os,re,sys,hashlib
W=sys.argv[1]; mode=sys.argv[2]
SL=os.path.expanduser('~/git-repos/Surelog')
h2d={}
for root in (os.path.join(SL,'tests'),os.path.join(SL,'third_party','tests')):
    for dp,_d,_f in os.walk(root):
        h2d[hashlib.sha1(dp.encode()).hexdigest()[:8]]=dp
tok=re.compile(r"(?:un)?signed\s*'\s*\(")
root=os.path.join(W,mode); hits=[]; unres=0
for d in sorted(os.listdir(root)):
    p=os.path.join(root,d,'cmds.txt')
    if not os.path.exists(p): continue
    name,_,h=d.rpartition('-')
    dp=h2d.get(h)
    if dp is None: unres+=1; continue
    m=re.search(r'^slang:\s+(.*)$',open(p,errors='replace').read(),re.M)
    if not m: continue
    args=m.group(1).split()
    files=[a for a in args[1:] if not a.startswith('-') and re.search(r'\.(sv|svh|v|vh)$',a)]
    found=[]
    for f in files:
        fp=f if os.path.isabs(f) else os.path.join(dp,f)
        if os.path.exists(fp):
            try:
                if tok.search(open(fp,errors='replace').read()): found.append(fp)
            except Exception: pass
    if found: hits.append((name,found))
for n,f in hits: print("CANDIDATE",n,len(f),f[0])
print("UNRESOLVED-DIRS %d"%unres)
print("PREDICTED-CANDIDATES %d"%len(hits))
