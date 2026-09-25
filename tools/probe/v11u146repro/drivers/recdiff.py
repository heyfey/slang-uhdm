import sys
# usage: recdiff.py <dir> : compares golden dump vs pris and law dumps record by record
d=sys.argv[1]
def rd(f):
    try: return open(f,errors='replace').read().split('\n')
    except: return None
ga=rd(d+'/pris.a.txt'); pb=rd(d+'/pris.b.txt'); lb=rd(d+'/law.b.txt'); la=rd(d+'/law.a.txt')
if not ga or not pb or not lb: print(d,'nodump'); sys.exit()
if ga!=la: print(d,'golden dumps differ between runs?!')
n=max(len(ga),len(pb),len(lb))
pd=[i for i in range(n) if (ga[i] if i<len(ga) else None)!=(pb[i] if i<len(pb) else None)]
ld=[i for i in range(n) if (ga[i] if i<len(ga) else None)!=(lb[i] if i<len(lb) else None)]
worse=[i for i in ld if i not in pd]
better=[i for i in pd if i not in ld]
print(f"{d} golden={len(ga)} pris_bad={len(pd)} law_bad={len(ld)} fixed={len(better)} newbad={len(worse)} len_p={len(pb)} len_l={len(lb)}")
for i in worse[:int(sys.argv[2]) if len(sys.argv)>2 else 0]:
    print('  NEWBAD #%d\n    G: %s\n    P: %s\n    L: %s'%(i,ga[i] if i<len(ga) else '-',pb[i] if i<len(pb) else '-',lb[i] if i<len(lb) else '-'))
