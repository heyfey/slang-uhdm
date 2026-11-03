import os,sys
wd,binp=sys.argv[1],sys.argv[2]
fen=[l.strip() for l in open('/tmp/v11u468_fenced.txt') if l.strip()]
for corp in ['surelog','uhdm2rtlil']:
    tot=named=other=0;fenced=0
    for root,dirs,files in os.walk(os.path.join(wd,corp)):
        if any(f in root for f in fen):
            fenced+=1; dirs[:]=[]; continue
        if 'cmds.txt' in files:
            tot+=1
            t=open(os.path.join(root,'cmds.txt'),errors='replace').read()
            if binp in t: named+=1
            elif 'slang-uhdm' in t or '/tmp/' in t and 'bin/' in t and 'surelog' not in t: other+=1
    print(corp,'records',tot,'naming',named,'other-binary',other)
n=0;tot=0
p=os.path.join(wd,'svtests')
for root,dirs,files in os.walk(p):
    if 'cmds.txt' in files:
        tot+=1
        if binp in open(os.path.join(root,'cmds.txt'),errors='replace').read(): n+=1
print('svtests records',tot,'naming',n)
