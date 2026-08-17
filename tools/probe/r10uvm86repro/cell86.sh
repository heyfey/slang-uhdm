#!/usr/bin/env bash
# r10uvm86 — the PER-CELL comparator.  MEASUREMENT-ONLY.
# Reduces both dumps of an arm workdir to, per ENCLOSING SUBROUTINE and per
# TOP-LEVEL LISTING (uhdmallPackages / uhdmtopPackages / ...), the ordered list
# of `operation`/`constant` headers plus their compared fields, then prints
# SAME/DIFF per cell.  A DIFF line quotes both sides verbatim — a cell is never
# summarised.
#   usage: cell86.sh <armdir> [pris|pat]
set -u
D=${1:?arm workdir}
T=${2:-pat}
python3 - "$D" "$T" <<'PY'
import re,sys
D,T=sys.argv[1],sys.argv[2]
def rep(f):
    try: lines=open(f).read().split('\n')
    except OSError: return None
    sect='?';cur='?';res={}
    for l in lines:
        if re.match(r'\|uhdm\w+:',l): sect=l.strip('|:')
        m=re.search(r'\\_(?:function|task): \(([\w:@.]+)\), line:(\d+):',l)
        if m: cur=m.group(1)
        m2=re.search(r'\\_(operation|constant): , line:(\d+):(\d+), endln:(\d+):(\d+)',l)
        if m2: res.setdefault((sect,cur),[]).append(
            f"{m2.group(1)}@{m2.group(2)}:{m2.group(3)}-{m2.group(4)}:{m2.group(5)}")
        m3=re.search(r'\|(vpiOpType|vpiDecompile|vpiSize|vpiConstType):(.*)',l)
        if m3: res.setdefault((sect,cur),[]).append(f"{m3.group(1)}={m3.group(2)}")
        m4=re.search(r'\|(INT|UINT|BIN|DEC|HEX|OCT|REAL|STRING|SCAL):(.*)',l)
        if m4: res.setdefault((sect,cur),[]).append(f"V={m4.group(1)}:{m4.group(2)}")
    return res
g=rep(f"{D}/g.dump"); o=rep(f"{D}/{T}.dump")
if g is None or o is None: print("MISSING DUMP"); sys.exit(1)
same=diff=0
for k in sorted(set(g)|set(o)):
    gv=g.get(k,[]); ov=o.get(k,[])
    if gv==ov: same+=1; continue
    diff+=1
    print(f"DIFF {k[0]}/{k[1]}")
    print(f"  G: {' '.join(gv)}")
    print(f"  O: {' '.join(ov)}")
print(f"cells_SAME={same} cells_DIFFER={diff}")
PY
