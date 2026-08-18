#!/usr/bin/env python3
# vrgg17 VIEW-GENERAL comparator: uhdm-dump three databases, normalise away ids,
# absolute paths and SPANS (no generated Compare reads a span), then score every
# dump line as a MULTISET: TO-GOLDEN / AWAY-GOLDEN / STILL-RIGHT / STILL-WRONG.
import sys, re, subprocess, collections
DUMP=subprocess.run
def norm(p):
    out=subprocess.run(['/home/heyfey/.local/bin/uhdm-dump',p],capture_output=True,text=True).stdout
    lines=[]
    for ln in out.split('\n'):
        ln=re.sub(r'\(@\d+\)','(@)',ln)              # object ids
        ln=re.sub(r'/[^ ,:]*/([^/ ,:]+\.s?v)',r'\1',ln)  # abs paths -> basename
        ln=re.sub(r'\b\d+:\d+:\d+:\d+\b','SPAN',ln)  # line:col:line:col
        ln=re.sub(r', line:\d+:\d+:\d+:\d+','',ln)
        ln=re.sub(r'\|(File|Line|Column)[^|]*\|','|',ln)
        ln=ln.strip()
        if ln: lines.append(ln)
    return collections.Counter(lines)
g,b,p=[norm(x) for x in sys.argv[1:4]]
tag=sys.argv[4] if len(sys.argv)>4 else ''
def d(x,y):
    r=collections.Counter()
    for k in set(x)|set(y):
        n=x[k]-y[k]
        if n: r[k]=n
    return r
db=d(g,b); dp=d(g,p)   # golden-minus-ours, signed
keys=set(db)|set(dp)
to=away=stillw=0
det=[]
for k in sorted(keys):
    vb=db.get(k,0); vp=dp.get(k,0)
    if abs(vp)<abs(vb): to+=1; det.append(('TO-GOLDEN',k,vb,vp))
    elif abs(vp)>abs(vb): away+=1; det.append(('AWAY',k,vb,vp))
    else:
        if vb!=vp: det.append(('SIDEWAYS',k,vb,vp)); away+=0
        stillw+=1
print(f"{tag} dumplines golden={sum(g.values())} base={sum(b.values())} pat={sum(p.values())} "
      f"| distinct-diff base={len(db)} pat={len(dp)} | TO-GOLDEN={to} AWAY={away} STILL-WRONG={stillw}")
for st,k,vb,vp in det:
    if st in ('AWAY','SIDEWAYS'):
        print(f"   {st} base={vb:+d} pat={vp:+d}  {k[:200]}")
