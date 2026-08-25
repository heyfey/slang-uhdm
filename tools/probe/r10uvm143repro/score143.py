#!/usr/bin/env python3
"""r10uvm143 — ARM SCORER for § hpIdxClassBodyNeverLateBinds143.

MEASUREMENT ONLY.  The official uhdm-cmp is the judge; this only classifies
cells so a pass that REMOVES bindings can score its ONE-SIDED sets explicitly.

LHS IS ALWAYS GOLDEN.  For every `hier_path` element bit_select INDEX in an
arm's dump it reads the reference's `vpiActual` kind and reports, per view:

  TO-GOLDEN     ours was wrong, moved, and now equals golden
  ALREADY-RIGHT ours equalled golden before and still does
  AWAY-GOLDEN   ours equalled golden before and no longer does   (must be 0)
  MOVED-WRONG   ours was wrong, moved, and is still wrong        (must be 0)
  STILL-WRONG   ours was wrong and did not move
  ONLY-GOLDEN   golden has the cell, we have no such object      (shape residue)
  ONLY-OURS     we have the cell, golden has no such object

The key is (reference fullname) and NOT any span: our path-element spans differ
from golden's by a separate, already-decoded family, and no generated `Compare`
reads a span (RESUME §9).

usage: score143.py <gold.dump> <pristine.dump> <patched.dump>
"""
import re, sys, collections

def cells(path):
    lines = open(path, errors='replace').read().split('\n')
    ind = [len(l) - len(l.lstrip(' ')) for l in lines]
    out = collections.Counter()
    for i, l in enumerate(lines):
        if not l.lstrip().startswith('\\_ref_obj: '):
            continue
        d = ind[i]
        if i + 1 >= len(lines) or ind[i + 1] != d + 2:
            continue                       # a bare reference print, not a listing
        # the enclosing printed object and the field this reference sits under
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
        nm = re.sub(r'\),.*$|\)$', '', nm)
        par = act = 'none'
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
        out[(nm, act)] += 1
    return out

def keyset(c):
    d = collections.defaultdict(collections.Counter)
    for (nm, act), n in c.items():
        d[nm][act] += n
    return d

g, o, q = (keyset(cells(p)) for p in sys.argv[1:4])
tally = collections.Counter()
for nm in sorted(set(g) | set(o) | set(q)):
    gv, ov, qv = g.get(nm), o.get(nm), q.get(nm)
    if gv is None:
        tally['ONLY-OURS'] += 1;  print('ONLY-OURS     %-50s %s' % (nm, dict(qv or ov))); continue
    if qv is None and ov is None:
        tally['ONLY-GOLDEN'] += 1; print('ONLY-GOLDEN   %-50s %s' % (nm, dict(gv))); continue
    if qv is None or ov is None:
        tally['OBJECT-APPEARED-OR-VANISHED'] += 1
        print('OBJ-DELTA     %-50s pris=%s pat=%s' % (nm, dict(ov or {}), dict(qv or {}))); continue
    same_o, same_q = (ov == gv), (qv == gv)
    if same_o and same_q:   tally['ALREADY-RIGHT'] += 1
    elif not same_o and same_q:
        tally['TO-GOLDEN'] += 1;  print('TO-GOLDEN     %-50s %s -> %s (gold %s)' % (nm, dict(ov), dict(qv), dict(gv)))
    elif same_o and not same_q:
        tally['AWAY-GOLDEN'] += 1; print('AWAY-GOLDEN   %-50s %s -> %s (gold %s)' % (nm, dict(ov), dict(qv), dict(gv)))
    elif ov != qv:
        tally['MOVED-WRONG'] += 1; print('MOVED-WRONG   %-50s %s -> %s (gold %s)' % (nm, dict(ov), dict(qv), dict(gv)))
    else:
        tally['STILL-WRONG'] += 1; print('STILL-WRONG   %-50s %s (gold %s)' % (nm, dict(ov), dict(gv)))
print('--- ' + '  '.join('%s=%d' % kv for kv in sorted(tally.items())))
