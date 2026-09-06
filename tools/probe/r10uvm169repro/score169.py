#!/usr/bin/env python3
"""r10uvm169repro/score169.py — the grid/census scorer.  MEASUREMENT ONLY.

    score169.py <cen.g.txt> <cen.a.txt> <cen.b.txt> [family]

Joins the three censuses as MULTISETS keyed by <run tag> x <owning subroutine
vpiFullName> x <return_stmt span> and scores every key that either binary
disagrees with golden on:

  TOWARD        pristine != golden, patched == golden
  AWAY          pristine == golden, patched != golden        (must be 0)
  STILL-WRONG   both differ from golden, and the patched value CHANGED
  UNMOVED       both differ from golden in the same way (untouched residue)
  BOTH-RIGHT    both equal golden (printed only in the totals)

LHS is ALWAYS golden; RHS is ALWAYS ours.  The RUN tag (`G.def` / `G.elab`) is
part of the key so the two views are never merged (r10uvm166 §6); the tag's
producer letter is stripped so golden and ours join.
"""
import sys, collections

def load(path, fam):
    m = collections.defaultdict(collections.Counter)
    for line in open(path, errors='replace'):
        line = line.rstrip('\n')
        if not line.startswith(fam + '|'):
            continue
        f = line.split('|')
        tag = f[1]
        view = tag.split('.', 1)[1] if '.' in tag else tag
        key = (view, f[2], f[3])
        m[key]['|'.join(f[4:])] += 1
    return m

g_path, a_path, b_path = sys.argv[1], sys.argv[2], sys.argv[3]
fam = sys.argv[4] if len(sys.argv) > 4 else 'RET'
g, a, b = load(g_path, fam), load(a_path, fam), load(b_path, fam)
keys = sorted(set(g) | set(a) | set(b))
tot = collections.Counter()
for k in keys:
    gv, av, bv = g[k], a[k], b[k]
    if av == gv and bv == gv:
        tot['BOTH-RIGHT'] += 1
        continue
    if av != gv and bv == gv:
        v = 'TOWARD'
    elif av == gv and bv != gv:
        v = 'AWAY'
    elif av == bv:
        v = 'UNMOVED'
    else:
        v = 'STILL-WRONG'
    tot[v] += 1
    print(('%-11s %-6s %-34s %s' % (v, k[0], k[1], k[2])).rstrip())
    print('    G=%s' % sorted(gv.elements()))
    print('    A=%s' % sorted(av.elements()))
    print('    B=%s' % sorted(bv.elements()))
print('-- %s cells: ' % fam +
      '  '.join('%s=%d' % (n, tot[n]) for n in
                ('BOTH-RIGHT', 'TOWARD', 'AWAY', 'STILL-WRONG', 'UNMOVED')))
