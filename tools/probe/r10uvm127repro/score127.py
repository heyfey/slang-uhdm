#!/usr/bin/env python3
"""r10uvm127 — CALL-ARGUMENT TYPESPEC SCORER.  MEASUREMENT ONLY.

Multiset join of ct127cen rows, golden vs pristine vs patched.

KEY   (id-free, span-bearing, view-bearing): the ARG's own span, its position,
      the callee's written name, the argument's VpiName, and the OWNER CHAIN
      with every `#id` stripped.  Ids differ between the two producers and
      between runs; spans and the chain do not.
PAYLOAD (what the judge reads through `expr::Compare`'s `Typespec()`): the
      ACTUAL typespec's KIND and its SPAN.  `none` when the argument carries no
      ref_typespec.  Object identity is deliberately NOT in the payload: no
      generated `Compare` reads VpiParent, so sharing vs copying is invisible
      to the judge (RESUME §9).

  TOGOLD      pristine != golden, patched == golden      (a fix)
  MOVEDWRONG  pristine == golden, patched != golden      (a break)
  MOVEDOTHER  all three differ
  SAME_AGREE  all three equal
  SAME_DIFF   pristine == patched != golden              (untouched residue)
  ONESIDED_*  a key present on one side only
  ONESIDED_PAT_CHANGED
              of the ONESIDED_PAT keys (ours only — golden holds NO object
              there, typically a call golden FOLDED AWAY), the ones whose
              payload the patch CHANGED.  These can never be scored against
              golden; they are reported so a payload write onto an
              already-one-sided cell is never invisible.
usage: score127.py <gold.cen> <pris.cen> <pat.cen>
"""
import sys, re, os, collections

# Which ARGUMENT KINDS enter the join.  Default `ref_obj` — the head's kind and
# the one whose VpiName makes a stable key.  `ARGKINDS=all` (or a comma list)
# widens it to the constant / operation actuals the same law stamps; their
# VpiName is empty, so the key leans on the span, which is unique per actual.
_kinds = os.environ.get('ARGKINDS', 'ref_obj')
ARGKINDS = None if _kinds == 'all' else set(_kinds.split(','))

def load(path):
    rows = collections.defaultdict(list)
    seen = set()          # one row per OBJECT: the listener revisits shared
                          # subtrees, and a visit count is not a cell count.
    for line in open(path):
        if not line.startswith('ARG '):
            continue
        f = dict()
        for m in re.finditer(r'([A-Z]+)=(\S*)', line.rstrip('\n')):
            f[m.group(1)] = m.group(2)
        if ARGKINDS is not None and f.get('AKIND') not in ARGKINDS:
            continue
        aid = f.get('AID')
        if aid in seen:
            continue
        seen.add(aid)
        ch = re.sub(r'#\d+', '', f.get('CH', '-'))
        ch = re.sub(r'^design\([^)]*\)/', '', ch)
        key = (ch, f.get('NAME'), f.get('IDX'), f.get('AKIND'), f.get('ANAME'),
               f.get('ASPAN'))
        val = (f.get('ATS'), f.get('ATSSPAN'))
        rows[key].append(val)
    # multiset per key
    return {k: collections.Counter(v) for k, v in rows.items()}

g, p, q = (load(a) for a in sys.argv[1:4])
keys = set(g) | set(p) | set(q)
tal = collections.Counter()
detail = collections.defaultdict(list)
for k in sorted(keys):
    G, P, Q = g.get(k), p.get(k), q.get(k)
    if G is None or P is None or Q is None:
        tag = 'ONESIDED_' + ('GOLD' if G is not None and P is None and Q is None
                             else 'PAT' if Q is not None and G is None
                             else 'MIXED')
        tal[tag] += 1
        detail[tag].append((k, G, P, Q))
        if tag == 'ONESIDED_PAT' and P != Q:
            tal['ONESIDED_PAT_CHANGED'] += 1
            detail['ONESIDED_PAT_CHANGED'].append((k, G, P, Q))
        continue
    if P == G and Q == G:
        tal['SAME_AGREE'] += 1
    elif P != G and Q == G:
        tal['TOGOLD'] += 1
        detail['TOGOLD'].append((k, G, P, Q))
    elif P == G and Q != G:
        tal['MOVEDWRONG'] += 1
        detail['MOVEDWRONG'].append((k, G, P, Q))
    elif P == Q and P != G:
        tal['SAME_DIFF'] += 1
        detail['SAME_DIFF'].append((k, G, P, Q))
    else:
        tal['MOVEDOTHER'] += 1
        detail['MOVEDOTHER'].append((k, G, P, Q))
for t in ('TOGOLD', 'MOVEDWRONG', 'MOVEDOTHER', 'SAME_DIFF', 'SAME_AGREE',
          'ONESIDED_GOLD', 'ONESIDED_PAT', 'ONESIDED_MIXED',
          'ONESIDED_PAT_CHANGED'):
    print('%-15s %d' % (t, tal[t]))
for t in ('TOGOLD', 'MOVEDWRONG', 'MOVEDOTHER', 'SAME_DIFF',
          'ONESIDED_PAT_CHANGED', 'ONESIDED_GOLD', 'ONESIDED_PAT',
          'ONESIDED_MIXED'):
    for k, G, P, Q in detail[t][:60]:
        print('%s | %s | G=%s P=%s Q=%s' % (t, ' '.join(map(str, k)),
                                            dict(G) if G else None,
                                            dict(P) if P else None,
                                            dict(Q) if Q else None))
