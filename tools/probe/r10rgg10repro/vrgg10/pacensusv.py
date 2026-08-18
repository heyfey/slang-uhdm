#!/usr/bin/env python3
"""Depth-keyed identity census of the head's own field:
for every param_assign in the ELAB view, the Rhs's typespec ACTUAL — kind,
location-or-LL — plus the Lhs parameter full name.  Compare-visible payload."""
import os, re, subprocess, sys
DUMP = os.path.expanduser('~/git-repos/UHDM/build/bin/uhdm-dump')
def depth(l):
    m = re.match(r'^(\s*)', l); return len(m.group(1))
def census(path, grid):
    r = subprocess.run([DUMP, path], capture_output=True, text=True, timeout=600)
    if r.returncode != 0: return None
    lines = [l.replace(grid, '@G') for l in r.stdout.split('\n')]
    # restrict to ELAB view
    try: start = next(i for i,l in enumerate(lines) if 'uhdmtopModules' in l)
    except StopIteration: return []
    lines = lines[start:]
    out = []
    for i, l in enumerate(lines):
        if '\\_param_assign:' not in l: continue
        d = depth(l)
        # walk forward while deeper
        rhs_actual = None; lhs = None; rhskind = None; seen_rhs = False
        j = i+1
        while j < len(lines) and (depth(lines[j]) > d or lines[j].strip()==''):
            s = lines[j]
            if depth(s) == d+2 and s.strip() == '|vpiRhs:':
                seen_rhs = True
                rhskind = lines[j+1].strip().split(':')[0].lstrip('\\_')
            if depth(s) == d+2 and s.strip() == '|vpiLhs:':
                lhs = lines[j+1].strip()
                seen_rhs = False
            if seen_rhs and s.strip() == '|vpiActual:' and rhs_actual is None:
                nxt = lines[j+1].strip()
                rhs_actual = re.sub(r', id:\d+', '', nxt)
            j += 1
        out.append('%s | rhs=%s | actual=%s' % (lhs, rhskind, rhs_actual))
    return sorted(out)
grid = sys.argv[1]
nbreak = 0
for name in sorted(os.listdir(grid)):
    d = os.path.join(grid, name)
    g = os.path.join(d,'sl/slpp_all/surelog.uhdm'); b=os.path.join(d,'base.uhdm'); p=os.path.join(d,'pat.uhdm')
    if not all(os.path.exists(x) for x in (g,b,p)): print('%-24s SKIP-NOFILE'%name); continue
    G,B,P = census(g,grid), census(b,grid), census(p,grid)
    if G is None or B is None or P is None: print('%-24s DUMPFAIL'%name); continue
    # key on the Lhs name
    def bykey(rows):
        d2={}
        for r in rows:
            k=r.split(' | ')[0]; d2.setdefault(k,[]).append(r)
        return d2
    gk,bk,pk = bykey(G),bykey(B),bykey(P)
    fixed=[]; broke=[]
    for k in set(gk)|set(bk)|set(pk):
        gv=sorted(gk.get(k,[])); bv=sorted(bk.get(k,[])); pv=sorted(pk.get(k,[]))
        bok = gv==bv; pok = gv==pv
        if bok and not pok: broke.append((k,gv,bv,pv))
        if (not bok) and pok: fixed.append(k)
    v='SAME'
    if broke and fixed: v='MIXED'
    elif broke: v='BROKEN'
    elif fixed: v='FIXED'
    print('%-24s %-8s rows=%d fixed=%d broken=%d'%(name,v,len(gk),len(fixed),len(broke)))
    for k,gv,bv,pv in broke:
        nbreak+=1
        print('    BREAK %s'%k)
        print('       golden: %s'%(gv,)); print('       base  : %s'%(bv,)); print('       pat   : %s'%(pv,))
print('== TOTAL BREAK CELLS=%d'%nbreak)
