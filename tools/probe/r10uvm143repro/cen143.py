#!/usr/bin/env python3
"""r10uvm143 — CORPUS CELL CENSUS for § hpIdxClassBodyNeverLateBinds143.

MEASUREMENT ONLY; the official uhdm-cmp is the judge.  LHS IS ALWAYS GOLDEN.

Reads two uhdm-dump outputs and classifies every `hier_path` element bit_select
INDEX reference by whether it carries a `vpiActual`, joined on
(reference fullname, own loc) — the reference's OWN location, which the two
producers agree on, never the bit_select's span, which they do not (and which no
generated `Compare` reads).

  AGREE / OURS-OVERBOUND / OURS-UNDERBOUND     -- keys both sides build
  ONLY-GOLDEN-CELL / ONLY-OURS-CELL            -- hier_path SHAPE residue

usage: cen143.py <golden.dump> <ours.dump>
"""
import re, sys, collections

def cells(path):
    lines = open(path, errors='replace').read().split('\n')
    ind = [len(l) - len(l.lstrip(' ')) for l in lines]
    out = collections.defaultdict(lambda: [0, 0])     # key -> [total, bound]
    for i, l in enumerate(lines):
        if not l.lstrip().startswith('\\_ref_obj: '):
            continue
        d = ind[i]
        if i + 1 >= len(lines) or ind[i + 1] != d + 2:
            continue
        enc = fld = None
        for k in range(i - 1, -1, -1):
            if ind[k] == d and lines[k].lstrip().startswith('|') and fld is None:
                fld = lines[k].lstrip()[1:].split(':')[0]
            if ind[k] == d - 2 and lines[k].lstrip().startswith('\\_'):
                enc = lines[k].lstrip()[2:].split(':')[0]
                break
            if ind[k] < d - 2:
                break
        if enc != 'bit_select' or fld != 'vpiIndex':
            continue
        nm = re.sub(r'^ *\\_ref_obj: \(', '', l)
        loc = re.sub(r'^ *\\_ref_obj: \([^)]*\), ', '', l)
        nm = re.sub(r'\),.*$|\)$', '', nm)
        par, act = 'none', 'none'
        for j in range(i + 1, len(lines)):
            if ind[j] <= d:
                break
            if ind[j] != d + 2:
                continue
            t = lines[j].lstrip()
            if t.startswith('|vpiParent:'):
                par = lines[j + 1].lstrip()[2:].split(':')[0]
            elif t.startswith('|vpiActual:'):
                act = lines[j + 1].lstrip()[2:].split(':')[0]
        if par != 'hier_path':
            continue
        k = (nm, loc)
        out[k][0] += 1
        if act != 'none':
            out[k][1] += 1
    return out

G, O = cells(sys.argv[1]), cells(sys.argv[2])
t = collections.Counter()
for k in sorted(set(G) | set(O)):
    gt, gb = G.get(k, (0, 0))
    ot, ob = O.get(k, (0, 0))
    if gt == 0:
        t['ONLY-OURS-CELL'] += 1
    elif ot == 0:
        t['ONLY-GOLDEN-CELL'] += 1
    elif gb == ob:
        t['AGREE'] += 1
    elif ob > gb:
        t['OURS-OVERBOUND'] += 1
        print('OURS-OVERBOUND  %s %s  gold %d/%d  ours %d/%d' % (k[0], k[1], gb, gt, ob, ot))
    else:
        t['OURS-UNDERBOUND'] += 1
        print('OURS-UNDERBOUND %s %s  gold %d/%d  ours %d/%d' % (k[0], k[1], gb, gt, ob, ot))
for kk, vv in sorted(t.items()):
    print('%-18s %d' % (kk, vv))
