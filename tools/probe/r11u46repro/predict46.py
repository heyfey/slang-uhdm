import os,re,sys,subprocess
W=sys.argv[1]; mode=sys.argv[2]
root=os.path.join(W,mode)
hits=[]
tok=re.compile(r"(?:un)?signed\s*'\s*\(")
for d in sorted(os.listdir(root)):
    p=os.path.join(root,d,'cmds.txt')
    if not os.path.exists(p): continue
    name=d.rsplit('-',1)[0]
    txt=open(p,errors='replace').read()
    m=re.search(r'^slang:\s+(.*)$',txt,re.M)
    if not m: continue
    args=m.group(1).split()
    files=[a for a in args[1:] if not a.startswith('-') and re.search(r'\.(sv|svh|v|vh)$',a)]
    # resolve relative to the test source dir
    base=None
    for cand in (os.path.join(os.path.expanduser('~/git-repos/uhdm2rtlil/test'),name),):
        if os.path.isdir(cand): base=cand
    found=[]
    for f in files:
        fp=f if os.path.isabs(f) else (os.path.join(base,f) if base else None)
        if fp and os.path.exists(fp):
            try:
                if tok.search(open(fp,errors='replace').read()): found.append(fp)
            except Exception: pass
    if found: hits.append((name,found))
for n,f in hits: print(n, len(f), f[0])
print("PREDICTED-MOVERS %d"%len(hits))
