# r10uvm80repro/namecmp80.py -- the PER-NAME judge.  usage:
#   namecmp80.py <golden NAMES> <before NAMES> <after NAMES> <tag>
# Reads three `R10UVM80_NAMES=1 r10uvm80cen` outputs and prints the fullname
# MULTISET distance before and after, the count of names the AFTER side produces
# that GOLDEN LACKS (must be 0), and the count of GOLDEN names the after side
# newly produces.  A per-shape aggregate can hide a field-level regression
# inside a net-improving line (r10uvm79 V-F2), so the two counts are reported
# separately from the distance and never summed into it.
import collections,sys
def rd(p):
    c=collections.Counter()
    for ln in open(p,errors='replace'):
        if ln.startswith('NAME\t'): c[ln[5:].rstrip('\n')]+=1
    return c
g,a,b=rd(sys.argv[1]),rd(sys.argv[2]),rd(sys.argv[3])
d=lambda x,y: sum(abs(x[k]-y[k]) for k in set(x)|set(y))
newbad=[k for k in b if b[k]>g.get(k,0) and b[k]>a.get(k,0)]
fixed=[k for k in g if g[k]>a.get(k,0) and b.get(k,0)>a.get(k,0)]
print("%s objects g=%d law1=%d law1+2=%d | NAME-multiset dist law1=%d law1+2=%d | new-names-golden-lacks=%d | golden-names-newly-produced=%d"%(
 sys.argv[4],sum(g.values()),sum(a.values()),sum(b.values()),d(g,a),d(g,b),len(newbad),len(fixed)))
for k in fixed[:6]: print("   FIXED ",k)
for k in newbad[:6]: print("   NEWBAD",k)
