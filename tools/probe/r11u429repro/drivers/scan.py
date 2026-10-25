import os, re, sys
fence=[l.strip() for l in open('/tmp/r11u429_scratch/fence.txt') if l.strip()]
SR='/home/heyfey/git-repos/slang-uhdm/third_party/Surelog'
roots={'surelog':[SR+'/tests', SR+'/third_party/tests'],
       'u2r':['/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test'],
       'probe':['/home/heyfey/git-repos/slang-uhdm/tests/probe']}
paths=[]
for tag,rs in roots.items():
    for r in rs:
        for dp,ds,fs in os.walk(r):
            for f in fs:
                if f.endswith(('.sv','.v','.svh','.vh','.sl','.f')):
                    paths.append((tag,os.path.join(dp,f)))
n0=len(paths)
paths=[(t,p) for t,p in paths if not any(fn in p for fn in fence)]
print('listed',n0,'after fence',len(paths), file=sys.stderr)
rb=re.compile(r'\$bits\s*\(\s*[A-Za-z_][\w$]*\s*\)')
rp=re.compile(r'\b(always\w*|initial|final)\b')
rg=re.compile(r'\b(generate|genvar)\b|\bif\s*\(|\bfor\s*\(')
rc=re.compile(r"\b[A-Za-z_][\w$]*(::[A-Za-z_][\w$]*)*'\(")
rcls=re.compile(r'\bclass\b')
rfield=re.compile(r'`uvm_field_')
out={'law2':set(),'law1':set()}
for t,p in paths:
    if p.endswith(('.sl','.f')): continue
    try: s=open(p,errors='replace').read()
    except Exception: continue
    d=os.path.dirname(p)
    if rb.search(s) and rp.search(s) and rg.search(s): out['law2'].add((t,d))
    if rcls.search(s) and (rc.search(s) or rfield.search(s)): out['law1'].add((t,d))
for k,v in out.items():
    for t,d in sorted(v): print(k,t,d)
