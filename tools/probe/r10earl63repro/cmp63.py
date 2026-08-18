#!/usr/bin/env python3
"""r10earl63 — MULTISET JOIN of two pacen63 censuses (golden vs ours).

MEASUREMENT ONLY.  Key = (SEC, owner, param name).  Prints one row per key
with golden's and ours' Compare-visible constant fields, marked SAME / DIFF,
and a per-family tally.  Multiset (never a last-writer dict): duplicate keys
are paired in order.
"""
import sys, collections

def load(p):
    d = collections.defaultdict(list)
    for ln in open(p):
        t = ln.split()
        if not t or t[0] != 'PA':
            continue
        sec, own, loc, nm, kind = t[1], t[2], t[3], t[4], t[5]
        rest = ' '.join(t[6:])
        d[(sec, own, nm)].append((kind, rest))
    return d

def main():
    g, o = load(sys.argv[1]), load(sys.argv[2])
    only = sys.argv[3] if len(sys.argv) > 3 else None
    keys = sorted(set(g) | set(o))
    same = diff = 0
    for k in keys:
        gv, ov = g.get(k, []), o.get(k, [])
        n = max(len(gv), len(ov))
        for i in range(n):
            a = gv[i] if i < len(gv) else ('<absent>', '')
            b = ov[i] if i < len(ov) else ('<absent>', '')
            eq = (a == b)
            if eq:
                same += 1
            else:
                diff += 1
            if only == 'diff' and eq:
                continue
            if only == 'same' and not eq:
                continue
            print('%-5s %-28s %-34s %-6s | G %s %s | O %s %s' %
                  (k[0], k[1], k[2], 'SAME' if eq else 'DIFF',
                   a[0], a[1], b[0], b[1]))
    print('TOTAL same=%d diff=%d' % (same, diff))

main()
