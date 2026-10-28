#!/usr/bin/env python3
# scan.py: candidate rows for § oobInheritedCallBindsOwnPkgClone455 by source text:
# a row is a candidate when its non-UVM-library sources hold an out-of-body
# class-method definition (function/task header naming C::m) AND a package.
# Every path list is filtered on the fence list before any file is opened.
import os, re, sys, glob
F=[l.strip() for l in open('/tmp/r11u455_fenced.txt') if l.strip()]
def fenced(p): return any(f in p for f in F)
OOB=re.compile(r'^\s*(?:(?:virtual|static|protected|local)\s+)*(?:function|task)\b[^;\n]*?\b\w+\s*::\s*\w+\s*[\(;]', re.M)
PKG=re.compile(r'^\s*package\s+\w+', re.M)
CACHE={}
def one(f):
    if f in CACHE: return CACHE[f]
    r=(False,False)
    if not(fenced(f) or '/UVM/' in f or 'uvm-1' in f or not os.path.isfile(f)):
        try:
            t=re.sub(r'//[^\n]*','',open(f,errors='replace').read()); r=(bool(OOB.search(t)),bool(PKG.search(t)))
        except Exception: pass
    CACHE[f]=r; return r
def check(files):
    o=p=False
    for f in set(files):
        a,b=one(f); o|=a; p|=b
    return o and p
    for f in files:
        if fenced(f) or '/UVM/' in f or 'uvm-1' in f or not os.path.isfile(f): continue
        try: t=open(f,errors='replace').read()
        except Exception: continue
        t=re.sub(r'//[^\n]*','',t)
        if OOB.search(t): o=True
        if PKG.search(t): p=True
    return o and p
out={}
root='/home/heyfey/git-repos/slang-uhdm'
# probe: case dirs that hold sources
pc=[]
for d,_,fs in os.walk(root+'/tests/probe'):
    if fenced(d): continue
    src=[os.path.join(d,f) for f in fs if f.endswith(('.sv','.v','.svh','.vh'))]
    if src and check(src): pc.append(os.path.relpath(d,root+'/tests/probe'))
out['probe']=pc
for name,base in (('surelog',root+'/third_party/Surelog/tests'),('uhdm2rtlil',root+'/third_party/uhdm2rtlil/test')):
    c=[]
    for t in sorted(os.listdir(base)):
        if fenced(t): continue
        d=os.path.join(base,t)
        if not os.path.isdir(d): continue
        src=[]
        for dd,_,fs in os.walk(d):
            if fenced(dd): continue
            src+= [os.path.join(dd,f) for f in fs if f.endswith(('.sv','.v','.svh','.vh','.pkg'))]
        if check(src): c.append(t)
    out[name]=c
# sv-tests: from the control's cmds.txt
sv=[]
wr='/tmp/intr11u452/svtests/work'
for d,_,fs in os.walk(wr):
    if 'cmds.txt' not in fs or fenced(d): continue
    line=[l for l in open(os.path.join(d,'cmds.txt')) if l.startswith('slang:')]
    if not line: continue
    toks=line[0].split()[1:]
    files=[t for t in toks if t.endswith(('.sv','.v','.svh','.vh')) and t.startswith('/')]
    for t in toks:
        if t.startswith('-I') and '/UVM/' not in t:
            inc=t[2:]
            if os.path.isdir(inc):
                files+= glob.glob(inc+'/*.sv*')+glob.glob(inc+'/*.v')
    for t in list(files):
        dd=os.path.dirname(t)
        if '/UVM/' not in dd: files+= glob.glob(dd+'/*.sv*')+glob.glob(dd+'/*.v')
    if check(files): sv.append(os.path.relpath(d,wr))
out['svtests']=sv
for k,v in out.items():
    open('/tmp/r11u455_cand_'+k+'.lst','w').write('\n'.join(v)+('\n' if v else ''))
    print(k,len(v))
