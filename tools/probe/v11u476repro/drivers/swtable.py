#!/usr/bin/env python3
# swtable.py <pris.txt> <law.txt> <sw_*.txt>...: per switch, the dirs whose md5 moves off the law's
# and of them those back on pristine's (the runcase.sh lines' md5 field)
import sys, re
def rd(p):
    d = {}
    for l in open(p):
        m = re.search(r'md5=(\w+)', l)
        if m: d[l.split()[0]] = m.group(1)
    return d
P, L = rd(sys.argv[1]), rd(sys.argv[2])
print(f'dirs {len(L)} law!=pristine {sum(1 for k in L if L[k] != P.get(k))}')
for f in sys.argv[3:]:
    S = rd(f); name = re.search(r'sw_(\w+)\.txt', f).group(1)
    off = [k for k in sorted(L) if S.get(k) != L[k]]
    back = [k for k in off if S.get(k) == P.get(k)]
    eqp = sum(1 for k in L if S.get(k) == P.get(k))
    print(f'{name}: ==pristine {eqp}/{len(L)}; moves off the law: {" ".join(off)} | of them back to pristine: {" ".join(back)}')
