import os,sys
fen=[l.strip() for l in open('/tmp/v11u443_fenced.txt') if l.strip()]
root,binpath=sys.argv[1],sys.argv[2]
for st in ['surelog','uhdm2rtlil','svtests','downstream','probe']:
    d=os.path.join(root,st)
    if not os.path.isdir(d): continue
    paths=[]
    for dp,dn,fn in os.walk(d):
        for f in fn:
            if f=='cmds.txt': paths.append(os.path.join(dp,f))
    n0=len(paths); paths=[p for p in paths if not any(n in p for n in fen)]
    ours=other=onlysl=0
    for p in paths:
        t=open(p,errors='replace').read()
        if binpath in t: ours+=1
        elif 'slang-uhdm' in t or '/tmp/' in t and 'law' in t: other+=1
        else: onlysl+=1
    print(st,'cmds',n0,'fence-filtered',len(paths),'naming-bin',ours,'other-binary',other,'no-binary',onlysl)
