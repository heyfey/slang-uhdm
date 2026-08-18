#!/usr/bin/env bash
# r10uvm94 — the THREE-WAY arm table: golden vs PRISTINE vs PATCHED, one line
# per hier_path whose NAME carries a bracket, keyed on the SPAN (our databases
# do not always carry a VpiFile on a hier_path).  MEASUREMENT-ONLY.
#   usage: three92.sh <arm workdir>
# Prints FIXED / BROKE / STILL-WRONG / ALREADY-OK and the counts.  A BROKE line
# is a pristine-right -> patched-wrong cell and is the reading that must be
# zero before anything lands.
set -u
D=${1:?arm workdir}
CEN=${CEN:-/tmp/r10uvm94_ct94cen}
for t in slpp_all/surelog:g pris:o pat:p; do
  f=${t%%:*}; tag=${t##*:}
  [ -f "$D/$f.uhdm" ] || { echo "MISSING $D/$f.uhdm"; exit 5; }
  "$CEN" "$D/$f.uhdm" --brk 2>/dev/null | sed 's/^[^|]*|/|/;s/\tSITE=.*//' > "$D/three.$tag"
done
python3 - "$D" <<'PY'
import re,sys
D=sys.argv[1]
def load(p):
    d={}
    for ln in open(p):
        k=ln.split('\t')[0]
        m=re.search(r'NAME=([^\t]*)',ln)
        d[k]=m.group(1) if m else ''
    return d
g=load(D+'/three.g'); a=load(D+'/three.o'); b=load(D+'/three.p')
fx=br=ok=st=0
for k in sorted(set(g)|set(a)|set(b), key=lambda x:(int(x.split(':')[0][1:]),x)):
    G=g.get(k,'<none>'); A=a.get(k,'<none>'); B=b.get(k,'<none>')
    if A==G and B==G: ok+=1; continue
    if A!=G and B==G: fx+=1; print(f"FIXED  {k:22} G={G}")
    elif A==G and B!=G: br+=1; print(f"BROKE  {k:22} G={G:40} pat={B}")
    else: st+=1; print(f"STILL  {k:22} G={G:40} pris={A:34} pat={B}")
print(f"-- cells={len(set(g)|set(a)|set(b))} ALREADY-OK={ok} FIXED={fx} BROKE={br} STILL-WRONG={st}")
PY
