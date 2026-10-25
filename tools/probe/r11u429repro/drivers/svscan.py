import os,re,csv
fence=[l.strip() for l in open('/tmp/r11u429_scratch/fence.txt') if l.strip()]
ST='/home/heyfey/git-repos/sv-tests'
rows=[r[0] for r in csv.reader(open('/home/heyfey/git-repos/slang-uhdm/results/golden_svtests.csv')) if r and r[0]!='case']
rb=re.compile(r'\$bits\s*\(\s*[A-Za-z_][\w$]*\s*\)')
rp=re.compile(r'\b(always\w*|initial|final)\b')
rg=re.compile(r'\b(generate|genvar)\b|\bif\s*\(|\bfor\s*\(')
rc=re.compile(r"\b[A-Za-z_][\w$]*(::[A-Za-z_][\w$]*)*'\(")
rcls=re.compile(r'\bclass\b'); rf=re.compile(r'`uvm_field_')
c1=[];c2=[]
for rel in rows:
    if any(f in rel for f in fence): continue
    p=os.path.join(ST,'tests',rel)
    try: s=open(p,errors='replace').read()
    except Exception: continue
    files=[p]
    m=re.search(r':files:(.*)',s)
    if m: files+= [f for f in m.group(1).split() if not any(x in f for x in fence)]
    m=re.search(r':incdirs:(.*)',s)
    inc=m.group(1).split() if m else []
    txt=''
    for f in files:
        try: txt+=open(f,errors='replace').read()
        except Exception: pass
    # include files in incdirs (shallow) too
    for d in inc:
        if any(x in d for x in fence): continue
        try:
            for fn in os.listdir(d):
                if fn.endswith(('.sv','.svh','.v','.vh')) and not any(x in fn for x in fence):
                    try: txt+=open(os.path.join(d,fn),errors='replace').read()
                    except Exception: pass
        except Exception: pass
    if rb.search(txt) and rp.search(txt) and rg.search(txt): c2.append(rel)
    if rcls.search(txt) and (rc.search(txt) or rf.search(txt)): c1.append(rel)
open('/tmp/r11u429_scan/sv_law1.lst','w').write('\n'.join(c1)+'\n')
open('/tmp/r11u429_scan/sv_law2.lst','w').write('\n'.join(c2)+'\n')
print(len(rows),len(c1),len(c2))
