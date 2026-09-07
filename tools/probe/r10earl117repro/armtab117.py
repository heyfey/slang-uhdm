#!/usr/bin/env python3
"""r10earl117 — the per-CELL arm table: golden / pristine / patched, one row per
sig117 key, printed only where the three do not all agree, plus a per-arm
assertion that the KEY SET is identical on all three sides (a key that appears
on one side only would be a moved SPAN, which the F0 family alone cannot name).

MEASUREMENT ONLY.  LHS is ALWAYS golden; RHS is ALWAYS ours.
usage: armtab117.py <griddir> <arm> <view>
"""
import sys, collections

def load(p):
    per = collections.defaultdict(collections.Counter)
    for l in open(p):
        if not l.startswith('S|'):
            continue
        f = l.rstrip('\n').split('|')
        if len(f) < 13:
            continue
        per[tuple(f[2:11])][tuple(f[11:13])] += 1
    return per

d, arm, view = sys.argv[1], sys.argv[2], sys.argv[3]
base = "%s/%s_%s" % (d, arm, view)
g, p, a = load(base + "/sig.gold.txt"), load(base + "/sig.pris.txt"), load(base + "/sig.patch.txt")
print("### %s %s   keys gold=%d pris=%d patch=%d" % (arm, view, len(g), len(p), len(a)))
if set(p) != set(a):
    print("  KEYSET-MOVED  only-pris=%s  only-patch=%s" %
          (sorted(set(p) - set(a)), sorted(set(a) - set(p))))
else:
    print("  KEYSET IDENTICAL pristine vs patched (no span moved)")
def rend(c):
    return ",".join("%s:%s x%d" % (k[0], k[1], v) for k, v in sorted(c.items()))
for k in sorted(set(g) | set(p) | set(a)):
    if g[k] == p[k] == a[k]:
        continue
    verdict = ("TOGOLD" if (p[k] != g[k] and a[k] == g[k]) else
               "AWAY" if (p[k] == g[k] and a[k] != g[k]) else
               "STILLWRONG" if p[k] == a[k] else "MOVEDWRONG")
    print("  %-11s %s" % (verdict, '|'.join(k)))
    print("      G: %s" % rend(g[k]))
    print("      P: %s" % rend(p[k]))
    print("      A: %s" % rend(a[k]))
