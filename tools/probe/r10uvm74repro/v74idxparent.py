#!/usr/bin/env python3
"""VERIFIER instrument — the field ct74cen.py does NOT test.

The law's convention (c) is about the vpiIndex child's PARENT (hier_path for a
non-constant, ABSENT for a constant).  ct74cen.py records only whether a
vpiIndex exists, and ct74cells.sh prints only the index child's KIND.  Neither
can see a wrongly-parented index, which is exactly the shape r10uvm73's VpiSize
trap taught this campaign to look for.

Key is (text, start line:col) exactly as ct74cen.py, so the two tables join.

  usage: idxparent.py <golden.dump> <ours.dump>
"""
import re
import sys
from collections import defaultdict

OBJ = re.compile(r'^(\s*)\\_(\w+): \((.*)\), line:(\d+):(\d+), endln:(\d+):(\d+)$')
STEP = re.compile(r'^[A-Za-z_$][A-Za-z0-9_$]*(\.[A-Za-z_$][A-Za-z0-9_$]*)*'
                  r'\[[^\[\]]*\]$')


def scan(path):
    rows = {}
    lines = open(path, errors='replace').read().splitlines()
    n = len(lines)
    for i, ln in enumerate(lines):
        m = OBJ.match(ln)
        if not m:
            continue
        indent, kind, text, sl, sc, el, ec = m.groups()
        if kind != 'bit_select' or not STEP.match(text):
            continue
        base = len(indent)
        fld = None
        parent_is_hp = False
        ixkind = None
        ixparent = 'NONE'
        j = i + 1
        while j < n:
            s = lines[j]
            st = s.lstrip()
            ind = len(s) - len(st)
            if ind <= base and st.startswith('\\_'):
                break
            if ind < base:
                break
            if st.startswith('|') and ind == base + 2:
                fld = st[1:].split(':')[0]
            elif st.startswith('\\_') and ind == base + 2:
                mm = OBJ.match(s)
                if fld == 'vpiParent' and s.lstrip().startswith('\\_hier_path'):
                    parent_is_hp = True
                if fld == 'vpiIndex':
                    ixkind = st[2:].split(':')[0]
                    # walk the index child's own fields at base+4
                    k = j + 1
                    while k < n:
                        s2 = lines[k]
                        st2 = s2.lstrip()
                        ind2 = len(s2) - len(st2)
                        if ind2 <= base + 2:
                            break
                        if ind2 == base + 4 and st2.startswith('|vpiParent'):
                            kk = k + 1
                            if kk < n:
                                ixparent = lines[kk].lstrip()[2:].split(':')[0]
                            break
                        k += 1
            j += 1
        if not parent_is_hp:
            continue
        rows[(text, int(sl), int(sc))] = (ixkind or 'NOINDEX', ixparent)
    return rows


g, o = scan(sys.argv[1]), scan(sys.argv[2])
ks = set(g) & set(o)
print('golden bit_select steps=%d  ours=%d  shared=%d' % (len(g), len(o), len(ks)))
dis = [k for k in ks if g[k] != o[k]]
print('---- shared keys DISAGREEING on (index kind, index PARENT): %d' % len(dis))
t = defaultdict(int)
for k in dis:
    t[(g[k], o[k])] += 1
for (a, b), n in sorted(t.items(), key=lambda x: -x[1]):
    print('  %4d  LHS %-28s  RHS %s' % (n, a, b))
print('---- agreeing, by shape')
t2 = defaultdict(int)
for k in ks:
    if g[k] == o[k]:
        t2[g[k]] += 1
for a, n in sorted(t2.items(), key=lambda x: -x[1]):
    print('  %4d  %s' % (n, a))
if dis:
    print('---- every disagreeing key')
    for k in sorted(dis, key=lambda x: (x[1], x[2])):
        print('  %-40s @%d:%d  LHS %s  RHS %s' % (k[0], k[1], k[2], g[k], o[k]))
