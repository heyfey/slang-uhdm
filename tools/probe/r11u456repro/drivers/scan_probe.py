import os, re, glob
ROOT='/tmp/wt_r11u456/tests/probe'
F=[l.strip() for l in open('/tmp/r11u456_fenced.txt') if l.strip()]
A=re.compile(r'\binterface\b'); A2=re.compile(r'\b(task|function)\b')
B=re.compile(r'\bthis\b'); B2=re.compile(r'::')
out=[]
for g in sorted(glob.glob(os.path.join(ROOT,'**','dut.sv'),recursive=True)):
    rel=os.path.relpath(os.path.dirname(g),ROOT)
    if any(f in rel for f in F): continue
    d=os.path.dirname(g); txt=''
    for fn in os.listdir(d):
        if any(f in fn for f in F): continue
        if fn.endswith(('.sv','.svh','.v','.vh')):
            txt+=open(os.path.join(d,fn),errors='ignore').read()
    if (A.search(txt) and A2.search(txt)) or (B.search(txt) and B2.search(txt)) or 'uvm' in txt:
        out.append(rel)
open('/tmp/r11u456_scan/cand_probe.txt','w').write('\n'.join(out)+'\n')
print(len(out))
