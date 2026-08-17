#!/usr/bin/env bash
# three-way GOLDEN / PRISTINE / PATCHED hier_path-NAME table for an arm workdir
set -u
D=${1:?arm workdir}
cd "$D" || exit 3
for t in g pris pat; do
  src=$t.uhdm; [ $t = g ] && src=slpp_all/surelog.uhdm
  [ -f "$src" ] || { echo "MISSING $src"; exit 4; }
  /tmp/r10uvm89_ct89cen "$src" --paths 2>/dev/null |
    awk -F'\t' '{split($1,a,"|"); lv="";for(j=1;j<=NF;j++){if($j~/^LVAL=/)lv=substr($j,6); if($j~/^NAME=/)nm=substr($j,6)}; printf "%s\tLVAL=%s\t%s\n", a[2], lv, nm}' |
    sort -u > $t.names
done
python3 - <<'PY'
import re
def load(p):
    d={}
    for ln in open(p):
        a=ln.rstrip('\n').split('\t'); d.setdefault(a[0],[]).append((a[1],a[2]))
    return d
G=load('g.names'); P=load('pris.names'); A=load('pat.names')
def num(k):
    m=re.match(r'(\d+):(\d+)',k); return (int(m.group(1)),int(m.group(2)))
keys=sorted(set(G)|set(P)|set(A), key=num)
print("%-14s %-6s %-30s %-30s %-30s %s"%("SPAN","LVAL","GOLDEN","PRISTINE","PATCHED","VERDICT"))
nf=nb=ns=0
for k in keys:
    g=sorted(G.get(k,[('-','<absent>')])); p=sorted(P.get(k,[('-','<absent>')])); a=sorted(A.get(k,[('-','<absent>')]))
    for i in range(max(len(g),len(p),len(a))):
        gg=g[i] if i<len(g) else ('-','<absent>'); pp=p[i] if i<len(p) else ('-','<absent>'); aa=a[i] if i<len(a) else ('-','<absent>')
        if gg[1]==pp[1]==aa[1]: continue
        if gg[1]==aa[1] and gg[1]!=pp[1]: v='FIXED'; nf+=1
        elif gg[1]==pp[1] and gg[1]!=aa[1]: v='BROKE'; nb+=1
        else: v='STILL-WRONG'; ns+=1
        print("%-14s %-6s %-30s %-30s %-30s %s"%(k,gg[0],gg[1],pp[1],aa[1],v))
print("-- FIXED=%d BROKE=%d STILL-WRONG=%d"%(nf,nb,ns))
PY
