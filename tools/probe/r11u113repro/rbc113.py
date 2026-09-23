#!/usr/bin/env python3
# rbc113.py <gold-dump> <ours-dump> : the RANGE-BOUND constant cells.  Every `\_constant` block
# whose vpiParent is a `\_range` (the block = header + deeper lines, ids/files stripped) is
# a cell; the multisets are diffed and the gold-only / ours-only blocks printed (multiset-safe:
# counts, not sets).  Prints "RBC gold=<n> ours=<n> only_gold=<n> only_ours=<n>".
import sys, re, collections
def cells(path):
    L = open(path, errors='replace').read().split('\n'); out = collections.Counter()
    for i, l in enumerate(L):
        m = re.match(r'^(\s*)\\_constant: ', l)
        if not m or i + 2 >= len(L) or '|vpiParent:' not in L[i+1] or '\\_range:' not in L[i+2]: continue
        ind = len(m.group(1)); blk = [l.strip()]
        for l2 in L[i+1:]:
            ind2 = len(l2) - len(l2.lstrip())
            if not l2.strip() or ind2 <= ind: break
            blk.append(' ' * (ind2 - ind) + l2.strip())
        b = re.sub(r', id:\d+', '', '\n'.join(blk)); b = re.sub(r'file:[^,]*,', '', b)
        out[b] += 1
    return out
g, o = cells(sys.argv[1]), cells(sys.argv[2])
og, oo = g - o, o - g
for b, n in sorted(og.items()): print(f'GOLD-ONLY [{n}x] ' + b.replace('\n', ' | '))
for b, n in sorted(oo.items()): print(f'OURS-ONLY [{n}x] ' + b.replace('\n', ' | '))
print(f'RBC gold={sum(g.values())} ours={sum(o.values())} only_gold={sum(og.values())} only_ours={sum(oo.values())}')
