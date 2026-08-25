#!/usr/bin/env python3
"""r10earl87 — THE CORPUS 3-WAY SCORE, per cell AND per field.

MEASUREMENT ONLY (the official uhdm-cmp is the judge).  Takes the BEFORE
census (`cen87.sh` over the PRISTINE workdir: G rows = golden, O rows = ours)
and the AFTER census (same driver over the PATCHED workdir; its O rows are the
PATCHED side, its G rows are the same goldens and are used only to assert the
universe did not move).  Joins per DATABASE as a MULTISET on the census KEY
(keys collide, so a last-writer dict would silently DROP rows -- RESUME.md s9).

  WRONG->RIGHT / RIGHT->WRONG / WRONG->OTHER / STILL-WRONG / SAME   per CELL
  TO-GOLDEN / AWAY-GOLDEN / MOVED-WRONG                            per FIELD

usage: cen3way87.py <before.cells> <after.cells>
"""
import sys, collections

def load(p):
    per = collections.defaultdict(lambda: collections.defaultdict(lambda: ([], [])))
    for line in open(p, errors='replace'):
        line = line.rstrip('\n')
        if '\t' not in line or '|' not in line:
            continue
        side, db, row = line.split('\t', 2)
        k, v = row.split('|', 1)
        per[db][k.strip()][0 if side == 'G' else 1].append(v.strip())
    return per

def fields(v):
    return dict(x.split('=', 1) for x in v.split() if '=' in x)

before, after = load(sys.argv[1]), load(sys.argv[2])
cell = collections.Counter()
fld = collections.Counter()
moved = collections.Counter()
detail = []
gmismatch = 0
for db in sorted(set(before) | set(after)):
    kb, ka = before.get(db, {}), after.get(db, {})
    for k in sorted(set(kb) | set(ka)):
        gl0, ol = kb.get(k, ([], []))
        gl1, ql = ka.get(k, ([], []))
        gl0, gl1, ol, ql = sorted(gl0), sorted(gl1), sorted(ol), sorted(ql)
        if gl0 != gl1:
            gmismatch += 1
        n = max(len(gl0), len(ol), len(ql))
        for i in range(n):
            g = gl0[i] if i < len(gl0) else None
            o = ol[i] if i < len(ol) else None
            q = ql[i] if i < len(ql) else None
            if g is None or o is None or q is None:
                cell['UNJOINED'] += 1
                continue
            if o == g and q == g:
                cell['SAME'] += 1
            elif o != g and q == g:
                cell['WRONG->RIGHT'] += 1; detail.append(('W2R', db, k))
            elif o == g and q != g:
                cell['RIGHT->WRONG'] += 1; detail.append(('R2W', db, k))
            elif o == q:
                cell['STILL-WRONG'] += 1
            else:
                cell['WRONG->OTHER'] += 1; detail.append(('W2O', db, k))
            gf, of, qf = fields(g), fields(o), fields(q)
            for f in sorted(set(gf) | set(of) | set(qf)):
                gv, ov, qv = gf.get(f), of.get(f), qf.get(f)
                if ov == qv:
                    continue
                moved[f] += 1
                if qv == gv:
                    fld['TO-GOLDEN'] += 1
                elif ov == gv:
                    fld['AWAY-GOLDEN'] += 1
                else:
                    fld['MOVED-WRONG'] += 1

print('golden-side keys that changed between the two censuses: %d '
      '(must be 0 -- the universe is fixed)' % gmismatch)
print('CELL  ' + ' '.join('%s=%d' % (k, cell[k]) for k in
      ('SAME', 'WRONG->RIGHT', 'RIGHT->WRONG', 'WRONG->OTHER', 'STILL-WRONG',
       'UNJOINED')))
print('FIELD ' + ' '.join('%s=%d' % (k, fld[k]) for k in
      ('TO-GOLDEN', 'AWAY-GOLDEN', 'MOVED-WRONG')) +
      '   fields moved: ' + ', '.join('%sx%d' % kv for kv in sorted(moved.items())))
for tag, db, k in detail:
    print('   %-4s %-42s %s' % (tag, db, k))
