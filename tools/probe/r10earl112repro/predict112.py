#!/usr/bin/env python3
"""r10earl112 -- PREDICT THE MOVER SET BY NAME, from PRISTINE databases only.

MEASUREMENT ONLY.  The official uhdm-cmp is the sole acceptance judge.
LHS is ALWAYS golden; RHS is ALWAYS ours.

RESUME.md section 6, gate 5: "every mover named+attributed; PREDICT the mover
set BY NAME from pristine databases FIRST".  This reads ONE censweep112
rows.tsv taken with the PRISTINE binary and names, per corpus row, every
`hier_path` cell § patCaGenIdxValueRender112 can reach:

    the key exists on BOTH sides, and
    OURS carries a `ctx=operation75...` (or `tagged_pattern<operation75`)
        diagnostic at gd >= 1 with `idx=ref`, and
    GOLDEN carries `idx=const` at the same key
        with a name that differs from ours.

Everything else is RISK: a cell the law must NOT move.  Both lists are printed
in full, and the ROW names are printed last -- that list is the prediction the
byte verifier is checked against.

  usage: predict112.py <pristine-sweep rows.tsv>
"""
import sys
from collections import defaultdict, Counter


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    # side -> row -> key -> (Counter(payload), set(diagnostics))
    data = defaultdict(lambda: defaultdict(lambda: defaultdict(
        lambda: [Counter(), set()])))
    with open(sys.argv[1]) as f:
        for line in f:
            p = line.rstrip('\n').split('\t')
            if len(p) < 5:
                continue
            side, row, key, pay, cnt = p[0], p[1], p[2], p[3], int(p[4])
            diag = p[5] if len(p) > 5 else ''
            cell = data[side][row][key]
            cell[0][pay] += cnt
            for d in diag.split(','):
                cell[1].add(d)

    move, risk = [], []
    for row in sorted(set(data['G']) | set(data['O'])):
        gk, ok = data['G'].get(row, {}), data['O'].get(row, {})
        for key in sorted(set(gk) | set(ok)):
            if not key.startswith('HPN|'):
                continue
            if key not in gk or key not in ok:
                risk.append((row, key, gk.get(key), ok.get(key), 'ONE-SIDED'))
                continue
            G, O = gk[key], ok[key]
            oPat = any(('ctx=operation75' in d or 'tagged_pattern<operation75' in d)
                       and 'idx=ref' in d and
                       not d.endswith('gd=0;idx=ref')
                       for d in O[1])
            gConst = any('idx=const' in d for d in G[1])
            if oPat and gConst and set(G[0]) != set(O[0]):
                move.append((row, key, G, O, 'MOVE'))
            elif set(G[0]) != set(O[0]):
                risk.append((row, key, G, O, 'WRONG-BUT-NOT-OURS'))
            else:
                risk.append((row, key, G, O, 'AGREES'))

    print('--- PREDICTED MOVE cells: %d ---' % len(move))
    for row, key, G, O, _ in move:
        print('%s\t%s\n\tG %s\n\tO %s\n\tDIAG %s' %
              (row, key, dict(G[0]), dict(O[0]), sorted(O[1])))
    agrees = sum(1 for r in risk if r[4] == 'AGREES')
    print('--- RISK cells (must not move): %d  (of which already AGREEING %d) ---'
          % (len(risk), agrees))
    rows = sorted({r for r, _, _, _, _ in move})
    print('ROWS PREDICTED TO MOVE (%d):' % len(rows))
    for r in rows:
        print('  ' + r)


main()
