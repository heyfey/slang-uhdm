#!/usr/bin/env python3
"""r10uvm227 — the MULTISET JOIN for the ct227cen cell census.

MEASUREMENT ONLY; `uhdm-cmp` is the sole acceptance judge.

Reads three census files for ONE row-mode — golden, pristine-ours, patched-ours
— and reports, per cell KEY (everything left of ' => '), whether the PAYLOAD
(the package that owns the callee) agrees with golden before and after.

Keys COLLIDE (a holder can write the same call twice at different spans is
already in the key, but two views of the same holder produce the same key), so
the join is a MULTISET join over Counters, never a last-writer dict — a dict
here silently drops rows (RESUME §9's census trap).

Verdicts, all measured against GOLDEN as LHS:
  TO-GOLDEN    the payload multiset for that key moved toward golden's
  AWAY-GOLDEN  it moved away  (must be 0)
  STILL-WRONG  it disagreed before and after, unchanged (must not grow)
  MOVED-WRONG  it changed to a payload golden does not have (must be 0)

usage: cen227.py <golden.cen> <pristine.cen> <patched.cen> [label]
"""
import sys
from collections import Counter, defaultdict


def load(path):
    per = defaultdict(Counter)
    n = 0
    with open(path) as f:
        for line in f:
            line = line.rstrip('\n')
            if not line.startswith('CELL '):
                continue
            key, _, payload = line[5:].partition(' => ')
            per[key][payload] += 1
            n += 1
    return per, n


def main():
    if len(sys.argv) < 4:
        print(__doc__)
        return 2
    g, ng = load(sys.argv[1])
    a, na = load(sys.argv[2])
    b, nb = load(sys.argv[3])
    label = sys.argv[4] if len(sys.argv) > 4 else sys.argv[1]
    keys = set(g) | set(a) | set(b)
    to_g = away = still = moved_wrong = agree = 0
    lines = []
    for k in sorted(keys):
        G, A, B = g.get(k, Counter()), a.get(k, Counter()), b.get(k, Counter())
        if A == B:
            if G == B:
                agree += 1
            else:
                still += 1
                lines.append('STILL-WRONG %s\n    golden=%s ours=%s' % (k, dict(G), dict(B)))
            continue
        # the multiset changed: classify by distance to golden
        da = sum((A - G).values()) + sum((G - A).values())
        db = sum((B - G).values()) + sum((G - B).values())
        if db < da:
            to_g += 1
            lines.append('TO-GOLDEN %s\n    golden=%s pristine=%s patched=%s'
                         % (k, dict(G), dict(A), dict(B)))
        elif db > da:
            away += 1
            lines.append('!! AWAY-GOLDEN %s\n    golden=%s pristine=%s patched=%s'
                         % (k, dict(G), dict(A), dict(B)))
        else:
            moved_wrong += 1
            lines.append('!! MOVED-WRONG %s\n    golden=%s pristine=%s patched=%s'
                         % (k, dict(G), dict(A), dict(B)))
    print('== %s  cells golden=%d pristine=%d patched=%d  keys=%d'
          % (label, ng, na, nb, len(keys)))
    for l in lines:
        print(l)
    print('-- %s  AGREE %d  TO-GOLDEN %d  AWAY-GOLDEN %d  MOVED-WRONG %d  STILL-WRONG %d'
          % (label, agree, to_g, away, moved_wrong, still))
    return 0


if __name__ == '__main__':
    sys.exit(main())
