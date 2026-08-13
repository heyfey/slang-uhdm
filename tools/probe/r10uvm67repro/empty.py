#!/usr/bin/env python3
"""r10uvm67 VERIFIER — EMPTY PRODUCT CELL census.

  usage: empty.py <label> <g.dump> <pristine.dump> <patched.dump>

An EMPTY PRODUCT CELL is agreement that costs nothing: golden has no object at
the key (-NOOBJ-), or ours does not, or BOTH sides are unbound (NULL vs NULL).
ct67cells.py never scores a one-sided key as SAME, but it DOES score
BOTH-DANGLING as SAME, so a SAME total can be mostly vacuous.  This lists every
such cell and flags the ones the patch CHANGED — binding a cell where golden has
no counterpart is minting agreement with nothing.
"""
def rows(g,o):
    out=subprocess.run([sys.executable,'ct67cells.py',g,o,'--all'],capture_output=True,text=True).stdout
    tb=out.split('TABLE B')[1]
    r=[]
    for ln in tb.splitlines():
        m=re.match(r"\s+(SAME|DIFF|UNMEASURED)\s+(\(.*?\))\s+G=(\S*)\s+O=(\S*)",ln)
        if m: r.append(m.groups())
    return r
label,g,p,q=sys.argv[1:5]
a={k:(s,gv,ov) for s,k,gv,ov in rows(g,p)}
b={k:(s,gv,ov) for s,k,gv,ov in rows(g,q)}
print("### %s"%label)
for k in sorted(set(a)|set(b)):
    sa,ga,oa=a.get(k,('-','',''));sb,gb,ob=b.get(k,('-','',''))
    empty_g = 'NOOBJ' in gb
    empty_o = 'NOOBJ' in ob
    allnull = (set(filter(None,ob.split(',')))=={'NULL'}) and (set(filter(None,gb.split(',')))=={'NULL'})
    if empty_g or empty_o or allnull:
        kind = 'GOLDEN-HAS-NO-OBJECT' if empty_g else ('OURS-HAS-NO-OBJECT' if empty_o else 'BOTH-DANGLING')
        moved = 'CHANGED-BY-PATCH' if (oa!=ob) else 'untouched'
        print("  EMPTY-PRODUCT %-22s %-42s status %s->%s  %s" % (kind, k[:42], sa, sb, moved))
        print("                 golden=%s"%gb[:70]); print("                 pris  =%s"%oa[:70]); print("                 patch =%s"%ob[:70])
