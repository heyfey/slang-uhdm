#!/usr/bin/env python3
"""r10uvm135 — the grid/arm SCORER.  MEASUREMENT ONLY.

Reads three ct135cen censuses of ONE arm (golden, pristine, patched) and prints
    * the IMPLICIT-NET cells per module, per view, as a three-column table;
    * the AIDX cells (an associative dimension whose index is a NAME), with the
      Actual_group column, per view.
LHS is ALWAYS golden.  The view column is printed but NEVER keyed on (the two
producers label the collections differently for some copies — RESUME §9).

  usage: score135.py <cen.g.txt> <cen.a.txt> <cen.b.txt>
"""
import sys, collections

def load(p):
    nets = collections.Counter(); aidx = collections.Counter()
    for l in open(p, encoding='utf8', errors='replace'):
        f = l.rstrip('\n').split('\t')
        if len(f) < 4: continue
        if f[1] == 'NET' and f[3] == 'IMPL':
            nets[(f[4], f[6], f[5])] += 1          # module, name, span
        elif f[1] == 'AIDX':
            aidx[(f[3], f[6], f[7], f[8], f[10])] += 1  # shape, owner, span, name, IMPL?
    return nets, aidx

g, ga = load(sys.argv[1]); a, aa = load(sys.argv[2]); b, ba = load(sys.argv[3])

def table(title, G, A, B):
    print('=== ' + title)
    keys = sorted(set(G) | set(A) | set(B), key=lambda k: [str(x) for x in k])
    to = away = still = 0
    for k in keys:
        cg, ca, cb = G[k], A[k], B[k]
        mark = ' '
        if ca != cg and cb == cg: mark = 'TO-GOLDEN'; to += 1
        elif ca == cg and cb != cg: mark = 'AWAY'; away += 1
        elif ca != cg and cb != cg: mark = 'STILL-WRONG'; still += 1
        if cg == ca == cb: continue
        print(f'  g={cg} pris={ca} pat={cb}  {mark:11s} ' + ' | '.join(str(x) for x in k))
    print(f'  -- cells {len(keys)}  TO-GOLDEN {to}  AWAY-GOLDEN {away}  STILL-WRONG {still}'
          f'  AGREE {len(keys)-to-away-still}')
    return to, away, still

t1 = table('IMPLICIT NETS  (module | name | span)', g, a, b)
t2 = table('ASSOC INDEX NAME CELLS  (shape | owner | span | name | actual-is-implicit-wire)', ga, aa, ba)
print(f'TOTALS: TO-GOLDEN {t1[0]+t2[0]}  AWAY-GOLDEN {t1[1]+t2[1]}  STILL-WRONG {t1[2]+t2[2]}')

# --- MOVED-WRONG assertion.  A cell's DISTANCE from golden is |count - golden|;
# a cell that CHANGED must not have got FURTHER from golden.  (A pure equality
# test flags a cell that moved 4 -> 3 against golden's 1 as wrong, when it moved
# TOWARD golden by one copy and is held short by the pre-existing copy-count
# residue.  Those are reported as PARTIAL.)
def moved(G, A, B, kind):
    bad = part = 0
    for k in sorted(set(A) | set(B), key=lambda k: [str(x) for x in k]):
        if A[k] == B[k]:
            continue
        da, db = abs(A[k] - G[k]), abs(B[k] - G[k])
        if db > da:
            bad += 1
            print(f'  MOVED-WRONG {kind} g={G[k]} pris={A[k]} pat={B[k]}  ' + ' | '.join(str(x) for x in k))
        elif db > 0:
            part += 1
            print(f'  PARTIAL     {kind} g={G[k]} pris={A[k]} pat={B[k]}  ' + ' | '.join(str(x) for x in k))
    return bad
mw = moved(g, a, b, 'NET') + moved(ga, aa, ba, 'AIDX')
print(f'MOVED-WRONG {mw}')
