#!/usr/bin/env python3
# r11u413 scan.py: list corpus source files (fence-filtered BEFORE opening), regex-scan for the pass-413 shapes
import os, re, sys
fence=[l.strip() for l in open('/tmp/r11u413_fence.txt') if l.strip()]
roots=['/home/heyfey/git-repos/slang-uhdm/third_party/Surelog/tests','/home/heyfey/git-repos/slang-uhdm/third_party/Surelog/third_party/tests',
 '/home/heyfey/git-repos/slang-uhdm/third_party/Surelog/third_party/UVM','/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test',
 '/tmp/wt_r11u413/tests/probe','/home/heyfey/git-repos/sv-tests/tests','/home/heyfey/git-repos/sv-tests/third_party']
ext=('.sv','.v','.svh','.vh','.inc','.svi','.vg')
files=[]
for r in roots:
    for dp,dn,fn in os.walk(r):
        if any(f in dp for f in fence): continue
        for f in fn:
            p=os.path.join(dp,f)
            if any(x in p for x in fence): continue
            if f.endswith(ext): files.append(p)
pats={
 'CLSCALLMEMBER': re.compile(r'\b[A-Za-z_]\w*(?:\s*#\s*\([^;]*?\))?\s*::\s*\w+\s*\([^;]*?\)\s*\.\s*[A-Za-z_]'),
 'IFCALLMEMBER': re.compile(r'\b[A-Za-z_]\w*\s*\.\s*\w+\s*\([^;()]*\)\s*\.\s*[A-Za-z_]'),
 'COPYLHS': re.compile(r'=\s*new\s+[A-Za-z_]'),
 'EMPTYCONCAT': re.compile(r'=\s*\{\s*\}'),
 'SUPERMEMBER': re.compile(r'\bsuper\s*\.\s*[A-Za-z_]\w*\b(?!\s*[\(\.])'),
 'UNQRAND': re.compile(r'(?<![\.\w:])randomize\s*\(\s*[A-Za-z_]'),
 'IFARRELEM': re.compile(r'new\s*\(\s*[A-Za-z_]\w*\s*\[\s*\w+\s*\]\s*\)|=\s*[A-Za-z_]\w*\s*\[\s*\w+\s*\]\s*;'),
}
hits={k:[] for k in pats}
print('files', len(files), file=sys.stderr)
for p in files:
    try: t=open(p,errors='replace').read()
    except Exception: continue
    t2=re.sub(r'//[^\n]*','',t)
    for k,rx in pats.items():
        for m in rx.finditer(t2):
            ln=t2.count('\n',0,m.start())+1
            hits[k].append(f'{p}:{ln}: {m.group(0)[:80]}')
for k,v in hits.items():
    print(k, len(v))
    with open(f'/tmp/r11u413_scan_{k}.txt','w') as f: f.write('\n'.join(v)+'\n')
