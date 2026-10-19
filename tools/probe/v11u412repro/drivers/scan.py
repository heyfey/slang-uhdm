import os,re,sys
fence=open('/tmp/v11u412_fence.re').read().split()
roots=['/home/heyfey/git-repos/slang-uhdm/third_party/Surelog/tests','/home/heyfey/git-repos/slang-uhdm/third_party/Surelog/third_party/tests',
 '/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test','/home/heyfey/git-repos/slang-uhdm/tests/probe','/home/heyfey/git-repos/sv-tests/tests',
 '/home/heyfey/git-repos/slang-uhdm/third_party/Surelog/third_party/UVM/1800.2-2017-1.0']
paths=[]
for r in roots:
    for dp,dn,fn in os.walk(r):
        for f in fn:
            if f.endswith(('.sv','.v','.svh','.vh','.svi','.inc','.pkg')):
                paths.append(os.path.join(dp,f))
n0=len(paths)
paths=[p for p in paths if not any(x in p for x in fence)]
print('paths',n0,'after fence',len(paths),file=sys.stderr)
fnre=re.compile(r'\bfunction\b(.*?)\bendfunction\b',re.S)
decl=re.compile(r'^\s*(?:(?:static|automatic|const|var)\s+)*(?:int|integer|logic|bit|reg|byte|shortint|longint|real|shortreal|string|time|realtime|chandle|[A-Za-z_]\w*(?:::\w+)?)\b[^=;()]*;?$')
kw=set('return if for foreach while case begin end assert void repeat do forever fork disable wait'.split())
sb=re.compile(r"\b(?:parameter|localparam)\b[^;]*?\d+\s*'[sS][bB]")
hits=[]; sbh=[]
for p in paths:
    try: t=open(p,errors='ignore').read()
    except: continue
    t2=re.sub(r'//[^\n]*','',t); t2=re.sub(r'/\*.*?\*/','',t2,flags=re.S)
    if sb.search(t2): sbh.append(p)
    for m in fnre.finditer(t2):
        body=m.group(1)
        hdr,sep,rest=body.partition(';')
        if not sep: continue
        stmts=[s.strip() for s in rest.split(';') if s.strip()]
        stmts=[s for s in stmts if not re.match(r'^(input|output|inout|ref)\b',s)]
        if len(stmts)!=1: continue
        s=stmts[0]
        w=s.split()[0] if s.split() else ''
        if w in kw or '=' in s or '(' in s or s.startswith(('`','@','#')): continue
        if decl.match(s+';') and len(s.split())>=2:
            hits.append((p,hdr.strip()[:60],s[:60]))
for h in hits: print('FN',*h,sep=' | ')
for p in sbh: print('SB',p)
