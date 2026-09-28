# v11u188: censum.py <trace dir>: one line per database (row-mode or probe case) with its law firing counts.
import sys, glob, collections
rows = collections.defaultdict(collections.Counter)
for f in glob.glob(sys.argv[1] + '/*.188'):
    L = open(f).read().splitlines()
    out = L[0][4:] if L and L[0].startswith('OUT ') else '?'
    p = out.split('/')
    key = p[-3] + '/' + p[-2].rsplit('-', 1)[0] if out.endswith('slang.uhdm') else p[-1]
    for l in L[1:]:
        rows[key][l.split(' ', 1)[0]] += 1
for k in sorted(rows):
    print(k, ' '.join(f'{a}={b}' for a, b in sorted(rows[k].items())))
