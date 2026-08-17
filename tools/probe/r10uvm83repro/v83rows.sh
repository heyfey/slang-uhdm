#!/usr/bin/env bash
# v83 VERIFIER — per-row unsupported_typespec vpiInstance table, GOLDEN vs
# PRISTINE vs PATCHED, over the real sweep workdirs.  Golden path from cmds.txt.
set -u
CTL=${CTL:?pristine workdir}; PAT=${PAT:?patched workdir}
TS=/tmp/v83_arms/v83ts
for spec in "$@"; do
  mode=${spec%%:*}; n=${spec#*:}
  for d in "$PAT/$mode/$n"-*/; do
    [ -d "$d" ] || continue
    G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)/golden.uhdm
    P="$CTL/$mode/$(basename $d)/slang.uhdm"
    Q="$d/slang.uhdm"
    [ -f "$G" ] && [ -f "$P" ] && [ -f "$Q" ] || { echo "== $mode/$n SKIP-NOFILE"; continue; }
    echo "======== $mode/$n"
    "$TS" "$G" | grep '::' > /tmp/v83_r_g.txt
    "$TS" "$P" | grep '::' > /tmp/v83_r_p.txt
    "$TS" "$Q" | grep '::' > /tmp/v83_r_q.txt
    python3 - <<'PY'
import collections
def rd(p):
    d=collections.defaultdict(collections.Counter)
    for l in open(p):
        l=l.rstrip('\n')
        if not l.startswith('TS\t'): continue
        parts=l.split('\t'); body=parts[1]; cnt=int(parts[2][1:])
        nm=body[:34].strip(); rest=body[34:].strip()
        sp,role=rest.rsplit(' ',1)
        d[(nm,sp.strip())][role]+=cnt
    return d
def fmt(c):
    return 'ABSENT' if not c else ','.join('%sx%d'%(k,v) for k,v in sorted(c.items()))
G=rd('/tmp/v83_r_g.txt');P=rd('/tmp/v83_r_p.txt');Q=rd('/tmp/v83_r_q.txt')
reg=fix=same=0; rows=[]
for k in sorted(set(G)|set(P)|set(Q)):
    g,p,q=fmt(G.get(k)),fmt(P.get(k)),fmt(Q.get(k))
    if p==g and q!=g: reg+=1; rows.append(('REGRESSED',k,g,p,q))
    elif p!=g and q==g: fix+=1; rows.append(('FIXED',k,g,p,q))
    elif p!=q: rows.append(('MOVED',k,g,p,q))
    elif g!=q: rows.append(('STILL-DIFF',k,g,p,q))
    else: same+=1
for t,k,g,p,q in rows:
    print("  %-11s %-26s %-20s G=%-34s P=%-24s Q=%-24s"%(t,k[0],k[1],g,p,q))
print("  -- REGRESSED=%d FIXED=%d ALREADY-EQUAL=%d"%(reg,fix,same))
PY
  done
done
