# usage: python3 classify.py <grid3 output> [law]  -> per case pristine -> verified (or law) class, then a tally
import re, sys, collections
tally = collections.Counter()
for ln in open(sys.argv[1]):
    if '|' not in ln: continue
    parts = ln.split('|'); k = parts[0].split()[0]
    def g(s, f):
        m = re.search(f + r'=(\S+)', s); return m.group(1) if m else None
    P, V = parts[1], parts[2 if len(sys.argv) > 2 else 3]
    ps, vs = g(P, 'strict'), g(V, 'strict')
    if g(P, 'md5') == g(V, 'md5'): c = 'byte-identical (' + ps + ')'
    else:
        pd, vd = int(g(P, 'dumpdist')), int(g(V, 'dumpdist'))
        c = '%s -> %s %s' % (ps, vs, 'closer' if vd < pd else ('FURTHER' if vd > pd else 'same-distance'))
    print(k, c); tally[c] += 1
for c, n in tally.most_common(): print('%4d %s' % (n, c))
