import os,re,sys
roots=[os.path.expanduser('~/git-repos/uhdm2rtlil/test'),
       os.path.expanduser('~/git-repos/Surelog/tests'),
       os.path.expanduser('~/git-repos/Surelog/third_party/tests')]
iface_re=re.compile(r'^\s*interface\b',re.M)
end_re=re.compile(r'^\s*endinterface\b',re.M)
# a net declaration with an initializer, inside an interface body
net_re=re.compile(r'^\s*(wire|tri|uwire|wand|wor|supply[01]|tri[01]|triand|trior|trireg)\b[^;=]*=[^;]*;',re.M)
both_re=re.compile(r'^\s*assign\s*\([^)]*\)\s*#',re.M)
nif=0; nnda=0; nboth=0; hits=[]; bhits=[]
for r in roots:
    for dp,_d,fs in os.walk(r):
        for f in fs:
            if not f.lower().endswith(('.v','.sv','.svh','.vh','.svi')): continue
            p=os.path.join(dp,f)
            try: t=open(p,errors='replace').read()
            except Exception: continue
            for m in both_re.finditer(t):
                nboth+=1; bhits.append((p,t[:m.start()].count('\n')+1,m.group(0).strip()[:70]))
            # interface bodies
            pos=0
            while True:
                s=iface_re.search(t,pos)
                if not s: break
                e=end_re.search(t,s.end())
                body=t[s.end():e.start()] if e else t[s.end():]
                nif+=1
                for m in net_re.finditer(body):
                    nnda+=1; hits.append((p,m.group(0).strip()[:70]))
                pos=e.end() if e else len(t)
print("interface bodies scanned:",nif)
print("net decls with initializer inside an interface:",nnda)
for h in hits[:25]: print("   NDA",h)
print("assign (strength) #delay sites:",nboth)
for h in bhits[:25]: print("   BOTH",h)
