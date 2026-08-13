#!/usr/bin/env python3
"""r10uvm67 VERIFIER — per-CELL TRANSITION audit (pristine -> patched).

  usage: trans.py <label> <g.dump> <pristine.dump> <patched.dump>

WHY IT EXISTS.  ct67cells.py prints SAME/DIFF/UNMEASURED *counts*.  Counts
cannot distinguish "one cell gained" from "two gained and one regressed" —
SAME=7 DIFF=6 -> SAME=8 DIFF=5 is consistent with both.  This joins the two
runs BY CELL KEY and prints every status change, plus the only number that can
veto a pass: SAME -> non-SAME.
"""
def cells(g,o):
    out=subprocess.run([sys.executable,'ct67cells.py',g,o,'--all'],capture_output=True,text=True).stdout
    tb=out.split('TABLE B')[1]
    d={}
    for ln in tb.splitlines():
        m=re.match(r"\s+(SAME|DIFF|UNMEASURED)\s+(\(.*?\))\s+G=",ln)
        if m: d[m.group(2)]=m.group(1)
    return d
t=sys.argv[1]; g=sys.argv[2]; p=sys.argv[3]; q=sys.argv[4]
a=cells(g,p); b=cells(g,q)
tr=collections.Counter()
for k in sorted(set(a)|set(b)):
    s1=a.get(k,'-ABSENT-'); s2=b.get(k,'-ABSENT-')
    tr[(s1,s2)]+=1
    if s1!=s2: print("  %-12s -> %-12s %s"%(s1,s2,k))
print("  TRANSITIONS %s: %s"%(t,dict(tr)))
bad=sum(v for (x,y),v in tr.items() if x=='SAME' and y!='SAME')
print("  SAME->non-SAME (REGRESSIONS): %d"%bad)
