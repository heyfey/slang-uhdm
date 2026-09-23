import csv, sys
def load(p, mode=None):
    d = {}
    for r in csv.DictReader(open(p)):
        if mode and r['mode'] != mode: continue
        d[(r['name'], r['mode'])] = r['status']
    return d
a = load(sys.argv[1], sys.argv[3] if len(sys.argv) > 3 else None); b = load(sys.argv[2])
keys = set(a) | set(b)
diff = [(k, a.get(k), b.get(k)) for k in sorted(keys) if a.get(k) != b.get(k)]
from collections import Counter
print('rows A=%d B=%d common=%d differ=%d' % (len(a), len(b), len(set(a)&set(b)), len(diff)))
for k, x, y in diff: print('  DIFF', k[0], k[1], x, '->', y)
cb = Counter(b.values()); print('  B status:', dict(cb))
