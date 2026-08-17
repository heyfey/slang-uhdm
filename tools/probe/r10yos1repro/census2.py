import os, re, sys
roots = [os.path.expanduser('~/git-repos/Surelog/tests'),
         os.path.expanduser('~/git-repos/Surelog/third_party/tests'),
         os.path.expanduser('~/git-repos/uhdm2rtlil/test')]
exts = ('.v','.sv','.svh','.vh')
kw = re.compile(r'\b(module|macromodule|interface|program|primitive)\b')
hits=[]; files=0
for r in roots:
    for dp,_,fns in os.walk(r):
        for fn in fns:
            if not fn.endswith(exts): continue
            p=os.path.join(dp,fn); files+=1
            try: t=open(p,errors='replace').read()
            except Exception: continue
            # strip line comments and block comments (crude but fine for a census)
            t=re.sub(r'//[^\n]*','',t); t=re.sub(r'/\*.*?\*/','',t,flags=re.S)
            for m in kw.finditer(t):
                j=m.end()
                while j<len(t) and t[j] in ' \t\r\n': j+=1
                if j<len(t) and t[j]=='\\':
                    k=j+1
                    while k<len(t) and t[k] not in ' \t\r\n': k+=1
                    nm=t[j+1:k]
                    if '.' in nm: hits.append((p,m.group(1),nm))
print("files scanned:",files)
print("dotted-name declarations found:",len(hits))
for h in sorted(set(hits)): print("  ",h[0],h[1],"\\"+h[2])
