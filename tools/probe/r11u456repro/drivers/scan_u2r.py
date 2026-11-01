import os, re
ROOT='/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test'
F=[l.strip() for l in open('/tmp/r11u456_fenced.txt') if l.strip()]
A=re.compile(r'\binterface\b'); A2=re.compile(r'\b(task|function)\b')
B=re.compile(r'\bthis\b'); B2=re.compile(r'::')
out=[]
for name in sorted(os.listdir(ROOT)):
    d=os.path.join(ROOT,name)
    if not os.path.isdir(d) or any(f in name for f in F): continue
    txt=''
    for dp,ds,fs in os.walk(d):
        if any(f in dp for f in F): ds[:]=[]; continue
        for fn in fs:
            if fn.endswith(('.sv','.svh','.v','.vh')) and not any(f in fn for f in F):
                try: txt+=open(os.path.join(dp,fn),errors='ignore').read()
                except OSError: pass
    if (A.search(txt) and A2.search(txt)) or (B.search(txt) and B2.search(txt)):
        out.append(name)
open('/tmp/r11u456_scan/cand_u2r.txt','w').write('\n'.join(out)+'\n')
print(len(out), out[:20])
