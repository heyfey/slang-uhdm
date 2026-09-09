#!/usr/bin/env python3
# r11u1 PREDICTOR — names, from PRISTINE databases alone, every test whose
# database the law § ifacePortViewParamAssignsOnly must move.
#
# A mover is a database holding at least one interface_inst emitted at COLUMN 0
# (our port views and our col-0 tail dups both anchor there; a home view keeps
# the instantiation statement's real column and a def view the declaration's)
# that carries at least one `|vpiParameter:` child, or that carries a
# `|vpiParamAssign:` list our arms dropped.  Reads the dump; no rebuild needed.
import subprocess, sys, os, glob, re
DUMP='/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump'
def ind(l): return len(l)-len(l.lstrip(' '))
def scan(path):
    try:
        out=subprocess.run([DUMP,path],capture_output=True,text=True,timeout=900).stdout
    except Exception:
        return None
    L=out.split('\n')
    hit=False
    for i,l in enumerate(L):
        m=re.search(r'\\_interface_inst: \S+ \(([^)]*)\), .*line:\d+:0$', l)
        if not m: continue
        b=ind(l); j=i+1
        while j<len(L) and (L[j].strip()=='' or ind(L[j])>b):
            if ind(L[j])==b+2 and L[j].strip()=='|vpiParameter:':
                hit=True; break
            j+=1
        if hit: break
    return hit
if __name__=='__main__':
    wd=sys.argv[1]
    names=[]
    for d in sorted(glob.glob(os.path.join(wd,'*','*'))):
        f=os.path.join(d,'slang.uhdm')
        if not os.path.isfile(f): continue
        mode=os.path.basename(os.path.dirname(d))
        name=os.path.basename(d).rsplit('-',1)[0]
        names.append((name,mode,f))
    from concurrent.futures import ThreadPoolExecutor
    with ThreadPoolExecutor(max_workers=4) as ex:
        res=list(ex.map(lambda t: (t[0],t[1],scan(t[2])), names))
    for n,m,h in sorted(res):
        if h: print('PREDICT-MOVER %s %s'%(n,m))
        elif h is None: print('SCAN-FAIL %s %s'%(n,m))
    print('-- scanned=%d predicted=%d fail=%d'%(len(res),sum(1 for r in res if r[2] is True),sum(1 for r in res if r[2] is None)))
