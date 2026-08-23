# r10buvm31repro/mover31.py — THE MOVER PREDICTOR.  MEASUREMENT ONLY.
#
#   mover31.py <census dir written by sweepcen31.sh + sweepceng31.sh>
#
# Reads the per-test VAR censuses and prints, per test-mode:
#   A — cells where OUR array_var (vpiArrayType 2/3/4) already carries the
#       pattern operation but its vpiReg ELEMENT does not: the class-scope
#       half of § assocPropPatternInitRidesElem31, i.e. the databases whose
#       ELEMENT gains a vpiExpr.
#   B — cells where GOLDEN's array_var carries the operation and OURS carries
#       nothing at all: the module/package-scope half, i.e. the databases
#       where BOTH carriers gain it.
# A + B IS the predicted mover set, by name, before any sweep.
import glob, os, re, collections
import sys
d=sys.argv[1] if len(sys.argv)>1 else '.'
rows=collections.defaultdict(lambda: {'G':[], 'O':[]})
for f in glob.glob(d+'/[go].*.txt'):
    for line in open(f):
        p=line.rstrip('\n').split('\t')
        if len(p)<10: continue
        tag=p[0]; side,rel=tag.split(':',1)
        rows[rel][side].append(p)
# For each test: cells (loc,kind,at,name) -> expr
def key(p): return (p[2],p[3],p[4],p[5])
A=[]; B=[]
for rel,v in sorted(rows.items()):
    g={}; o={}
    for p in v['G']: g.setdefault(key(p),[]).append(p)
    for p in v['O']: o.setdefault(key(p),[]).append(p)
    # A: our array_var at 2/3/4 with expr OP, element (same loc, at=0) with expr '-'
    aloc=set()
    for k,ps in o.items():
        loc,kind,at,name=k
        if kind=='array_var' and at in ('at=2','at=3','at=4'):
            for p in ps:
                if p[7].startswith('expr=OP'):
                    aloc.add((loc,p[7]))
    for k,ps in o.items():
        loc,kind,at,name=k
        if kind!='array_var' and at=='at=0':
            for p in ps:
                if p[7]=='expr=-':
                    for (l,e) in aloc:
                        if l==loc: A.append((rel,loc,kind,e))
    # B: golden array_var at 2/3/4 with expr OP, ours same key expr '-'
    for k,ps in g.items():
        loc,kind,at,name=k
        if kind=='array_var' and at in ('at=2','at=3','at=4'):
            gexpr=set(p[7] for p in ps)
            if any(x.startswith('expr=OP') for x in gexpr):
                oexpr=set(p[7] for p in o.get(k,[]))
                if oexpr and all(x=='expr=-' for x in oexpr):
                    B.append((rel,loc,name,sorted(gexpr)))
print("== A (class-scope element gains Expr) tests:",len(set(a[0] for a in A)),"cells:",len(A))
for rel in sorted(set(a[0] for a in A)): print("  A",rel, len([a for a in A if a[0]==rel]))
print("== B (module/pkg-scope array_var+element gain Expr) tests:",len(set(b[0] for b in B)),"cells:",len(B))
for rel in sorted(set(b[0] for b in B)): print("  B",rel, len([b for b in B if b[0]==rel]))
open(d+'/A.txt','w').write('\n'.join(map(str,A)))
open(d+'/B.txt','w').write('\n'.join(map(str,B)))
