#!/usr/bin/env python3
# r11u417 scan_foreach.py: the by-name prediction for § foreachArrayNamesClass417 /
# § foreachArrayNamesTypedef417: per test directory, the bare foreach array names
# that are also a class or typedef name in the same directory's sources (plus the
# UVM library when the directory names uvm).  Paths are fence-filtered before any
# file is opened.
import os, re, sys
fenced=[l.strip() for l in open('/tmp/r11u417_fenced.txt') if l.strip()]
roots=sys.argv[1:]
FE=re.compile(r'\bforeach\s*\(\s*([A-Za-z_]\w*)\s*\[')
CL=re.compile(r'\bclass\s+(?:automatic\s+)?([A-Za-z_]\w*)')
TD=re.compile(r'\btypedef\b[^;]*?\b([A-Za-z_]\w*)\s*(?:\[[^\]]*\]\s*)*;')
def scan(files):
    fe,cl=set(),set()
    for f in files:
        try: t=open(f,errors='replace').read()
        except Exception: continue
        t=re.sub(r'//.*','',t)
        fe|=set(FE.findall(t)); cl|=set(CL.findall(t)); cl|=set(TD.findall(t))
    return fe,cl
uvmdir='/home/heyfey/git-repos/slang-uhdm/third_party/Surelog/third_party/UVM'
uvmfiles=[os.path.join(d,f) for d,_,fs in os.walk(uvmdir) for f in fs if f.endswith(('.sv','.svh'))]
ufe,ucl=scan(uvmfiles)
print('UVM self-intersection:',sorted(ufe&ucl))
for root in roots:
    for d,_,fs in os.walk(root):
        if any(n in d for n in fenced): continue
        files=[os.path.join(d,f) for f in fs if f.endswith(('.sv','.v','.svh','.vh','.sl','.f')) and not any(n in f for n in fenced)]
        if not files: continue
        fe,cl=scan([f for f in files if not f.endswith(('.sl','.f'))])
        uvm=any('uvm' in open(f,errors='replace').read().lower() for f in files if f.endswith(('.sl','.f','.sv')))
        hit=fe&cl
        if uvm: hit|= (fe&ucl)|(ufe&cl)
        if hit: print(d, sorted(hit))
