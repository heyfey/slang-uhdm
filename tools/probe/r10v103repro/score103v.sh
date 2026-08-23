#!/usr/bin/env bash
# r10v103repro/score103v.sh — per-CELL scoring of one arm/view against GOLDEN.
# For every function/task owner it prints one of
#   SAME    golden == pristine == patched
#   TOGOLD  pristine != golden, patched == golden        (the law works)
#   AWAY    pristine == golden, patched != golden        (A REGRESSION)
#   STILL   pristine != golden, patched != golden, unchanged
#   MOVED?  pristine != golden, patched != golden, but CHANGED
# MEASUREMENT ONLY.
set -u
G=$1; P=$2; Q=$3; HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CEN=${CEN:-$HERE/cell103v.py}
T=$(mktemp -d /tmp/v103_score.XXXXXX)
for x in "G:$G" "P:$P" "Q:$Q"; do
  t=${x%%:*}; f=${x#*:}
  uhdm-dump "$f" 2>&1 </dev/null > "$T/d.$t"
  python3 "$CEN" "$T/d.$t" > "$T/c.$t"
done
python3 - "$T" <<'PY'
import sys
T=sys.argv[1]
def load(p):
    d={}
    for ln in open(T+'/c.'+p):
        k,rest=ln.rstrip('\n').split('\t',1)
        d[k]=rest
    return d
G,P,Q=load('G'),load('P'),load('Q')
keys=sorted(set(G)|set(P)|set(Q))
counts={}
for k in keys:
    g,p,q=G.get(k,'<absent>'),P.get(k,'<absent>'),Q.get(k,'<absent>')
    if g==p==q: v='SAME'
    elif p!=g and q==g: v='TOGOLD'
    elif p==g and q!=g: v='AWAY'
    elif p!=g and q!=g and p==q: v='STILL'
    else: v='MOVED?'
    counts[v]=counts.get(v,0)+1
    if v!='SAME':
        print('%-7s %s' % (v,k))
        print('    G: %s' % g[:600])
        print('    P: %s' % p[:600])
        print('    Q: %s' % q[:600])
print('SUMMARY ' + ' '.join('%s=%d'%(k,counts[k]) for k in sorted(counts)))
PY
rm -rf "$T"
