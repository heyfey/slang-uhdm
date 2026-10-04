#!/usr/bin/env python3
"""residue.py <clusters.tsv of the law sweep> <clusters.tsv of the base sweep> <out.tsv>: per UVM row-mode
(drivers/uvmrows.py output) the clusters still standing after the r11u234 laws, ranked by objects, with map 15's
ground and writer pin (tools/probe/r11u230map/cluster_index.csv), the objects at the base, and a mark for the
live pair B's named heads. Reads only the analyzer tables (no corpus source, no database)."""
import sys, os, re, csv, collections
HERE = os.path.dirname(os.path.abspath(__file__))
IDX = os.path.join(HERE, '..', '..', 'r11u230map', 'cluster_index.csv')
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('residue.py: source drivers/env.sh first (FENCED)')
idx = {r['cluster_id']: r for r in csv.DictReader(open(IDX))}
PAIRB = {'N0266': 'pair B r11u231 head (UVM_SEQ_ARB_TYPE)', 'N0337': 'pair B r11u231 head (this_type)',
         'N0072': 'pair B r11u231 head (this_type)', 'N0120': 'pair B r11u231 head'}
def load(p):
    D = collections.defaultdict(collections.Counter)
    for l in open(p):
        rm, cid, n, k = l.rstrip('\n').split('\t')
        if any(re.search(rf'\b{re.escape(x)}\b', rm) for x in F): sys.exit('residue.py: fenced row: refusing')
        D[rm][cid] += int(n)
    return D
L, B = load(sys.argv[1]), load(sys.argv[2])
with open(sys.argv[3], 'w') as f:
    f.write('row_mode\trank\tcluster\tobjects_law\tobjects_base\tground\tpair_b\twriter\n')
    for rm in L:
        for i, (cid, n) in enumerate(sorted(L[rm].items(), key=lambda kv: (-kv[1], kv[0])), 1):
            e = idx.get(cid, {})
            f.write(f"{rm}\t{i}\t{cid}\t{n}\t{B[rm].get(cid, 0)}\t{e.get('ground', '?')}\t{PAIRB.get(cid, '')}\t"
                    f"{(e.get('writer') or '')[:110]}\n")
print('rows', len(L), 'out', sys.argv[3])
