#!/usr/bin/env bash
# r10uvm90 — the GOLDEN / PRISTINE / PATCHED `new`/`super.new` argument table for
# ONE arm workdir.  LHS is ALWAYS golden.  MEASUREMENT-ONLY.
#   usage: three90.sh <arm workdir>
set -u
D=${1:?arm workdir}
CEN=${CEN:-/tmp/r10uvm90_ct90cen}
cd "$D" || exit 3
for t in g pris pat; do
  src=$t.uhdm; [ $t = g ] && src=slpp_all/surelog.uhdm
  [ -f "$src" ] || { echo "MISSING $src"; exit 4; }
  "$CEN" "$src" --all 2>/dev/null | sort > $t.cen
done
python3 - <<'PY'
def load(p):
    d={}
    for ln in open(p):
        a=ln.rstrip('\n').split('\t')
        d.setdefault(a[0],[]).append((a[3],a[4]))
    return d
G=load('g.cen'); P=load('pris.cen'); A=load('pat.cen')
keys=sorted(set(G)|set(P)|set(A))
print("%-34s %-9s %-9s %-9s %s"%("OWNER","GOLDEN","PRIS","PAT","VERDICT"))
nf=nb=ns=nk=0
for k in keys:
    g=sorted(G.get(k,[('<absent>','-')])); p=sorted(P.get(k,[('<absent>','-')])); a=sorted(A.get(k,[('<absent>','-')]))
    for i in range(max(len(g),len(p),len(a))):
        gg=g[i] if i<len(g) else ('<absent>','-')
        pp=p[i] if i<len(p) else ('<absent>','-')
        aa=a[i] if i<len(a) else ('<absent>','-')
        if gg==pp==aa: nk+=1; continue
        if gg==aa and gg!=pp: v='FIXED'; nf+=1
        elif gg==pp and gg!=aa: v='BROKE'; nb+=1
        else: v='STILL-WRONG'; ns+=1
        print("%-34s %-9s %-9s %-9s %s"%(k,gg[0],pp[0],aa[0],v))
        print("   G %s\n   P %s\n   A %s"%(gg[1],pp[1],aa[1]))
print("-- AGREE=%d FIXED=%d BROKE=%d STILL-WRONG=%d"%(nk,nf,nb,ns))
PY
