#!/usr/bin/env bash
# usage: cmpcast.sh <arm> <view>  -> prints golden/pris/patc verdicts per cast cell
set -u
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
A=$1; V=$2
G=${OUTROOT:-/tmp/v94_out}/pris_$A/$V/g.uhdm
P=${OUTROOT:-/tmp/v94_out}/pris_$A/$V/o.uhdm
Q=${OUTROOT:-/tmp/v94_out}/patc_$A/$V/o.uhdm
${CASTCEN:-/tmp/castcen} "$G" > ${TMPDIR:-/tmp}/v94_c.g 2>/dev/null
${CASTCEN:-/tmp/castcen} "$P" > ${TMPDIR:-/tmp}/v94_c.p 2>/dev/null
${CASTCEN:-/tmp/castcen} "$Q" > ${TMPDIR:-/tmp}/v94_c.q 2>/dev/null
python3 - "$A" "$V" "${TMPDIR:-/tmp}" <<'PY'
import sys
a,v,T=sys.argv[1],sys.argv[2],sys.argv[3]
def load(f):
    d={}
    for l in open(f):
        l=l.rstrip('\n')
        if '  =>  ' not in l: continue
        k,p=l.split('  =>  ',1)
        d.setdefault(k,[]).append(p)
    for k in d: d[k].sort()
    return d
g=load(T+'/v94_c.g'); p=load(T+'/v94_c.p'); q=load(T+'/v94_c.q')
keys=sorted(set(g)|set(p)|set(q))
wr=rw=same=nokey=0
rows=[]
for k in keys:
    gv=g.get(k); pv=p.get(k); qv=q.get(k)
    if gv is None or pv is None or qv is None:
        nokey+=1; rows.append(("NOKEY",k,gv,pv,qv)); continue
    if pv==qv:
        rows.append(("SAME" if gv==qv else "STILL-WRONG",k,gv,pv,qv))
        if gv==qv: same+=1
        continue
    if gv==qv: wr+=1; rows.append(("WRONG->RIGHT",k,gv,pv,qv))
    elif gv==pv: rw+=1; rows.append(("RIGHT->WRONG",k,gv,pv,qv))
    else: rows.append(("MOVED-STILL-WRONG",k,gv,pv,qv))
print(f"### {a} / {v}   cells={len(keys)} WRONG->RIGHT={wr} RIGHT->WRONG={rw} NOKEY={nokey}")
for t,k,gv,pv,qv in rows:
    if t=="SAME": continue
    print(f"  [{t}] {k}")
    print(f"      G={gv}")
    print(f"      P={pv}")
    print(f"      Q={qv}")
PY
