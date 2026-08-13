#!/usr/bin/env python3
# r10uvm73 VERIFIER — per-cell INITIALIZER table: for each named class property,
# print (var kind / init-expr node / the init-expr PARENT kind / every vpiSize
# under it) on BOTH sides.  ct73cells.sh reads the KIND and the TYPESPEC only,
# so it is blind to the initializer half this pass also legislates — that blind
# spot is how the "sized 64" clause shipped unrefuted.
#   usage: v73initcells.py <g.dump> <o.dump> <cell> [<cell> ...]
# GUARD: a cell in NEITHER dump prints UNKNOWN-CELL and is counted.
import re,sys
def rows(path):
    g=open(path).read().split('\n'); out={}
    for i,l in enumerate(g):
        m=re.search(r'\\_([a-z_]+_var): \([^)]*::(\w+)\), line',l)
        if not m: continue
        cell=m.group(2)
        if cell in out: continue
        ind=len(l)-len(l.lstrip()); blk=[l]
        for j in range(i+1,len(g)):
            lj=g[j]
            if lj.strip() and (len(lj)-len(lj.lstrip()))<=ind: break
            blk.append(lj)
        t='\n'.join(blk)
        ex=t.split('|vpiExpr:')
        if len(ex)<2: out[cell]=(m.group(1),'-','-','-'); continue
        e=ex[1]
        node=re.search(r'\\_(\w+):',e)
        p=re.search(r'\|vpiParent:\s*\n\s*\\_(\w+):',e)
        sz=re.findall(r'vpiSize:(\d+)',e)
        out[cell]=(m.group(1),node.group(1) if node else '?',p.group(1) if p else 'NOPARENT',','.join(sz))
    return out
G=rows(sys.argv[1]); O=rows(sys.argv[2])
print('%-14s %-38s %-38s %s'%('CELL','GOLDEN kind/expr/exprParent/sizes','OURS','VERDICT'))
ag=dis=unk=0
for c in sys.argv[3:]:
    g=G.get(c); o=O.get(c)
    if not g and not o: print('%-14s %-38s %-38s UNKNOWN-CELL'%(c,'-','-')); unk+=1; continue
    fs=lambda x: '%s/%s/%s/[%s]'%x if x else 'ABSENT'
    v='AGREE' if g==o else 'DISAGREE'
    if v=='AGREE': ag+=1
    else: dis+=1
    print('%-14s %-38s %-38s %s'%(c,fs(g),fs(o),v))
print('-- agree=%d DISAGREE=%d UNKNOWN-CELL=%d'%(ag,dis,unk))
