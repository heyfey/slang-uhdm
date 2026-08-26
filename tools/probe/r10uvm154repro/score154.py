# r10uvm154 — score a grid or arm set pristine -> patched AGAINST GOLDEN.
# MEASUREMENT ONLY; the official uhdm-cmp is the sole judge.
#
#   score154.py <pristine-workroot> <patched-workroot>
#
# For every enum_const cell present on all three sides (golden, pristine, ours)
# it prints one of TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG (wrong -> a DIFFERENT
# wrong) / STILL-WRONG / STILL-RIGHT, keyed on (name, occurrence) so the DEF
# listing and its elaborated twin are scored SEPARATELY.
import os,sys,re
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cells154 import cells
PRI,PAT = sys.argv[1], sys.argv[2]
def idx(l):
    d={}; c={}
    for nm,v,dec,sz in l:
        k=c.get(nm,0); c[nm]=k+1; d[(nm,k)]=(v,dec,sz)
    return d
tot={"TO-GOLDEN":0,"AWAY-GOLDEN":0,"STILL-WRONG":0,"STILL-RIGHT":0,"MOVED-WRONG":0}
det=[]
for a in sorted(os.listdir(PRI)):
    g=cells(os.path.join(PRI,a,"g.dump")); o1=cells(os.path.join(PRI,a,"o.dump"))
    o2=cells(os.path.join(PAT,a,"o.dump"))
    if g is None or o1 is None or o2 is None: continue
    gi,i1,i2 = idx(g),idx(o1),idx(o2)
    for k in sorted(set(gi)|set(i1)|set(i2)):
        if k[0].startswith("uvm_") or k[0] in ("FINISHED","RUNNING","WAITING","SUSPENDED","KILLED"): continue
        G=gi.get(k); A=i1.get(k); B=i2.get(k)
        if G is None or A is None or B is None: continue
        if A==B:
            tot["STILL-RIGHT" if A==G else "STILL-WRONG"] += 1
            continue
        if B==G: v="TO-GOLDEN"
        elif A==G: v="AWAY-GOLDEN"
        else: v="MOVED-WRONG"
        tot[v]+=1
        det.append((v,a,k[0],k[1],G,A,B))
for v,a,nm,i,G,A,B in det:
    print("%-11s %-28s %-6s v%d  G%s  PRIS%s  PAT%s"%(v,a,nm,i,G,A,B))
print("SCORE", tot)
