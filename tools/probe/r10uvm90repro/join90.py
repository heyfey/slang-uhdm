#!/usr/bin/env python3
"""r10uvm90 — the GOLDEN-vs-OURS join for `new`/`super.new` calls.  LHS IS GOLDEN.

The object is LOC-LESS, so the join key is (OWNER, NAME) and the value is the
MULTISET of argument-shape strings under it — that is exactly what
`method_func_call::Compare` sees (VpiName + the Tf_call_args vector), and a
multiset join is order-blind, which the MOVER RULE requires.

  usage: join90.py <golden.cen> <ours.cen>
classes:
  AGREE            same multiset
  ARGS-NULL-OURS   golden has a populated vector, ours has NARGS=-1
  ARGS-NULL-GOLDEN the mirror (golden itself carries no vector)
  ARGS-DIFFER      both populated, different
  GOLDEN-ONLY / OURS-ONLY   the key exists on one side only
"""
import sys, collections
def load(p):
    d = collections.defaultdict(list)
    for ln in open(p):
        a = ln.rstrip('\n').split('\t')
        d[(a[0], a[2])].append((a[3], a[4]))
    return d
G, O = load(sys.argv[1]), load(sys.argv[2])
cnt = collections.Counter()
rows = []
for k in sorted(set(G) | set(O)):
    g, o = sorted(G.get(k, [])), sorted(O.get(k, []))
    if not o:
        cnt['GOLDEN-ONLY'] += len(g); rows.append(('GOLDEN-ONLY', k, g, o)); continue
    if not g:
        cnt['OURS-ONLY'] += len(o); rows.append(('OURS-ONLY', k, g, o)); continue
    if g == o:
        cnt['AGREE'] += len(g); continue
    gn = [x[0] for x in g]; on = [x[0] for x in o]
    if 'NARGS=-1' in on and 'NARGS=-1' not in gn:
        c = 'ARGS-NULL-OURS'
    elif 'NARGS=-1' in gn and 'NARGS=-1' not in on:
        c = 'ARGS-NULL-GOLDEN'
    else:
        c = 'ARGS-DIFFER'
    cnt[c] += max(len(g), len(o)); rows.append((c, k, g, o))
for c, k, g, o in rows:
    print("%-17s %s %s\n   G %s\n   O %s" % (c, k[1], k[0],
          ' | '.join("%s %s" % x for x in g) or '<absent>',
          ' | '.join("%s %s" % x for x in o) or '<absent>'))
print("-- " + "  ".join("%s=%d" % (k, v) for k, v in sorted(cnt.items())))
