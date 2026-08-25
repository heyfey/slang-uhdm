#!/usr/bin/env python3
"""r10earl93 -- MEASUREMENT ONLY.  Classify one census family's MOVED-WRONG
cells and name the MASK-FAMILY ones: constant vs constant, same vpiSize, both
UINT:, and golden's value equal to ours under mask64(W) = (W%64==0) ? 0 :
(1<<(W%64))-1 for some W >= 64.  Every other class is printed with a count so
the family is a MEASUREMENT and not a guess.

usage: famclass93.py <cells-file> <PA|CS|CV>
"""
import sys,collections
def mask64(w):
    r=w%64
    return 0 if r==0 else ((1<<r)-1)
def parse(p):
    return dict(x.split('=',1) for x in p.split('\t') if '=' in x)
def val(d): return d.get('RVAL',d.get('VAL','-'))
def sz(d): return int(d.get('RSZ',d.get('SZ','0')))
def kind(d): return d.get('RK','constant')
want=sys.argv[2]
out=collections.Counter(); hits=[]
cur=None;G=[];O=[]
def flush():
    global cur
    if cur is None: return
    tag,key=cur
    fam=key.split('\t',1)[0]
    if fam!=want: return
    gs=[parse(p) for p in G]; os_=[parse(p) for p in O]
    if len(gs)!=1 or len(os_)!=1: out['multiplicity-or-multi']+=1; return
    g,o=gs[0],os_[0]
    if kind(g)!='constant' or kind(o)!='constant': out['kind-flip']+=1; return
    vg,vo=val(g),val(o)
    if sz(g)!=sz(o): out['size-diff']+=1; return
    if vg==vo: out['other-field']+=1; return
    if not (vg.startswith('UINT:') and vo.startswith('UINT:')): out['non-uint-value']+=1; return
    try:
        ng=int(vg[5:]); no=int(vo[5:])
    except ValueError:
        out["unparsable"]+=1; return
    if ng==no: out["value-text-only"]+=1; return
    w=sz(g)
    ok=[W for W in range(64,1025) if (no & mask64(W))==ng]
    if ok:
        out['MASK-FAMILY']+=1; hits.append((tag,key,w,ng,no,ok[:4]))
    else: out['other-value']+=1
for line in open(sys.argv[1]):
    if line.startswith('CELL\t'):
        flush(); p=line.rstrip('\n').split('\t',2); cur=(p[1],p[2]); G=[];O=[]
    elif line.startswith('  G x'): G.append(line.rstrip('\n').split('\t',1)[1])
    elif line.startswith('  O x'): O.append(line.rstrip('\n').split('\t',1)[1])
flush()
for k,v in out.most_common(): print("%-24s %d"%(k,v))
print("--- MASK-FAMILY cells")
for h in hits: print(h)
