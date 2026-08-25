#!/usr/bin/env python3
"""r10uvm125 — score one arm's cen125 census as a MULTISET join.

LHS IS ALWAYS GOLDEN.  Cells are keyed on (SITE, CALL, IDX) — kinds, names and
spans only, never object ids.  Reports, per producer view:
    SAME            cells whose payload matches golden's
    MOVED-WRONG     cells present on both sides with a DIFFERENT payload
    ONLY-GOLDEN     golden cells with no counterpart
    ONLY-OURS       our cells with no counterpart
MEASUREMENT ONLY — the official uhdm-cmp is the judge.
  usage: score125.py <g.cen> <ours.cen> [label]
"""
import sys, collections

def load(p):
    d = collections.defaultdict(list)
    for ln in open(p):
        ln = ln.rstrip('\n')
        if not ln.startswith('CELL\t'):
            continue
        f = ln.split('\t')
        key = (f[1], f[2], f[3])
        d[key].append('\t'.join(f[4:]))
    for k in d:
        d[k].sort()
    return d

g = load(sys.argv[1]); o = load(sys.argv[2])
lab = sys.argv[3] if len(sys.argv) > 3 else ''
same = wrong = 0
og = oo = 0
det = []
for k in set(g) | set(o):
    gv = collections.Counter(g.get(k, []))
    ov = collections.Counter(o.get(k, []))
    inter = gv & ov
    same += sum(inter.values())
    gr = gv - inter; orr = ov - inter
    n = min(sum(gr.values()), sum(orr.values()))
    wrong += n
    og += sum(gr.values()) - n
    oo += sum(orr.values()) - n
    for v in gr:
        det.append(('G', k, v))
    for v in orr:
        det.append(('O', k, v))
print("%-14s SAME=%d MOVED-WRONG=%d ONLY-GOLDEN=%d ONLY-OURS=%d" %
      (lab, same, wrong, og, oo))
for t, k, v in sorted(det):
    print("  %s %s|%s|%s  %s" % (t, k[0][-60:], k[1], k[2], v))
