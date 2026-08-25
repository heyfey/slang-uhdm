#!/usr/bin/env python3
# r10v90 — THE TYPESPEC-PRESENCE-ONLY VERDICT.  score3_90.py scores the WHOLE
# payload, so a cell that already differed in VAL/SZ hides a typespec flip
# under WRONG->OTHER / WRONG->WRONG.  This scorer looks at the SEVEN typespec
# fields alone (TS TSN TSSG TSVL TSRG TSAL TSIN TSCE) and reports, per cell,
# whether the PATCH moved the typespec toward golden or away from it.
#   TS-EXTRA  = golden has NO typespec, patched minted one   <- must be 0
#   TS-WRONG  = golden has one, patched has a DIFFERENT one  <- must be 0
#   TS-FIXED  = pristine missing/wrong, patched == golden
#   TS-RIGHT->WRONG = pristine matched golden, patched does not <- must be 0
import sys, os, collections
def load(p):
    d = collections.defaultdict(list)
    if not os.path.exists(p): return d
    for line in open(p):
        line=line.rstrip("\n")
        if "\t||\t" not in line: continue
        k,v=line.split("\t||\t",1)
        f=dict(x.split("=",1) for x in v.split("\t") if "=" in x)
        ts=tuple(f.get(n,"-") for n in ("TS","TSN","TSSG","TSVL","TSRG","TSAL","TSIN","TSCE"))
        d[k].append(ts)
    for k in d: d[k].sort()
    return d
D=sys.argv[1]; g=load(D+"/g.rows"); o=load(D+"/o.rows"); q=load(D+"/q.rows")
T=collections.Counter(); bad=[]
for k in sorted(set(g)|set(o)|set(q)):
    gl,ol,ql=g.get(k,[]),o.get(k,[]),q.get(k,[])
    for i in range(max(len(gl),len(ol),len(ql))):
        gv=gl[i] if i<len(gl) else None; ov=ol[i] if i<len(ol) else None; qv=ql[i] if i<len(ql) else None
        if gv is None or ov is None or qv is None:
            T["ONE-SIDED"]+=1; continue
        if ov==qv:
            T["TS-SAME "+("EQ" if qv==gv else "NE")]+=1; continue
        # the patch changed the typespec here
        if qv==gv: T["TS-FIXED"]+=1
        elif ov==gv:
            T["TS-RIGHT->WRONG"]+=1; bad.append(("RIGHT->WRONG",k,gv,ov,qv))
        elif gv[0]=="-": T["TS-EXTRA"]+=1; bad.append(("EXTRA",k,gv,ov,qv))
        else: T["TS-OTHER"]+=1; bad.append(("OTHER",k,gv,ov,qv))
for k in sorted(T): print("%-18s %d"%(k,T[k]))
for b in bad: print("  !! %s %s\n     G %s\n     O %s\n     Q %s"%(b[0],b[1].replace("\t"," "),b[2],b[3],b[4]))
